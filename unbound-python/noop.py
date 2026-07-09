"""No-op Unbound Python module used as a safe default.

Mount your own script and point `python: python-script` at it when you need
custom Python processing.
"""


def init(id, cfg):
    log_info("pythonmod: noop init")
    return True


def deinit(id):
    log_info("pythonmod: noop deinit")
    return True


def inform_super(id, qstate, superqstate, qdata):
    return True


def operate(id, event, qstate, qdata):
    if event in (MODULE_EVENT_NEW, MODULE_EVENT_PASS):
        qstate.ext_state[id] = MODULE_WAIT_MODULE
        return True

    if event == MODULE_EVENT_MODDONE:
        qstate.ext_state[id] = MODULE_FINISHED
        return True

    log_err("pythonmod: noop bad event: %s" % strmodulevent(event))
    qstate.ext_state[id] = MODULE_ERROR
    return True
