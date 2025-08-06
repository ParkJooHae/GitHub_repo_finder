import 'dart:async';

/// 연속적인 함수 호출을 지연시켜 마지막 호출만 실행하는 디바운서
class Debouncer {
  final Duration delay;
  Timer? _timer;
  int _callCount = 0;

  Debouncer({required this.delay});

  /// 함수 실행을 디바운싱
  /// [callback]이 연속으로 호출되면 이전 타이머를 취소하고 새로 시작
  void call(VoidCallback callback) {
    _callCount++;
    final currentCall = _callCount;
    
    _timer?.cancel();
    _timer = Timer(delay, () {
      // 콜백이 실행될 때 현재 호출 번호가 마지막 호출과 같은지 확인
      if (currentCall == _callCount) {
        callback();
      }
    });
  }

  /// 현재 대기 중인 타이머를 취소
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// 디바운서를 정리
  void dispose() {
    cancel();
  }

  /// 현재 타이머가 활성화되어 있는지 확인
  bool get isActive => _timer?.isActive ?? false;
}

typedef VoidCallback = void Function();