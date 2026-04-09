class SessionInvalidationBus {
  Future<void> Function()? _handler;
  bool _isDispatching = false;

  void register(Future<void> Function() handler) {
    _handler = handler;
  }

  Future<void> dispatch() async {
    if (_isDispatching) {
      return;
    }

    final handler = _handler;
    if (handler == null) {
      return;
    }

    _isDispatching = true;
    try {
      await handler();
    } finally {
      _isDispatching = false;
    }
  }
}
