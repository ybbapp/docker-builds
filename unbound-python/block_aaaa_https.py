"""Unbound Python module that returns NODATA for AAAA and HTTPS queries.

This is a conservative DNS response: NOERROR with an empty answer section means
"the name may exist, but this RR type has no data". It avoids the side effects
of NXDOMAIN while suppressing IPv6 AAAA and HTTPS/SVCB upgrade hints.
"""

BLOCKED_QTYPES = {
    28: "AAAA",
    65: "HTTPS",
}


def _qtype_name(qtype):
    return BLOCKED_QTYPES.get(qtype, str(qtype))


def init(id, cfg):
    log_info(
        "block_aaaa_https: loaded; blocking qtypes=%s"
        % ",".join(BLOCKED_QTYPES.values())
    )
    return True


def deinit(id):
    log_info("block_aaaa_https: unloaded")
    return True


def inform_super(id, qstate, superqstate, qdata):
    return True


def _return_nodata(id, qstate):
    qname = qstate.qinfo.qname_str
    qtype = qstate.qinfo.qtype
    qclass = qstate.qinfo.qclass

    msg = DNSMessage(
        qname,
        qtype,
        qclass,
        PKT_QR | PKT_RA,
    )

    if not msg.set_return_msg(qstate):
        log_err(
            "block_aaaa_https: failed to create NODATA response qname=%s qtype=%s"
            % (qname, _qtype_name(qtype))
        )
        qstate.ext_state[id] = MODULE_ERROR
        return True

    # Mark synthetic response as secure enough for Unbound's module pipeline.
    qstate.return_msg.rep.security = 2

    # NOERROR + empty answer = NODATA.
    qstate.return_rcode = RCODE_NOERROR
    qstate.ext_state[id] = MODULE_FINISHED
    return True


def operate(id, event, qstate, qdata):
    if event in (MODULE_EVENT_NEW, MODULE_EVENT_PASS):
        qtype = qstate.qinfo.qtype

        if qtype in BLOCKED_QTYPES:
            log_info(
                "block_aaaa_https: blocked qname=%s qtype=%s"
                % (qstate.qinfo.qname_str, _qtype_name(qtype))
            )
            return _return_nodata(id, qstate)

        qstate.ext_state[id] = MODULE_WAIT_MODULE
        return True

    if event == MODULE_EVENT_MODDONE:
        qstate.ext_state[id] = MODULE_FINISHED
        return True

    log_err("block_aaaa_https: unexpected event=%s" % strmodulevent(event))
    qstate.ext_state[id] = MODULE_ERROR
    return True
