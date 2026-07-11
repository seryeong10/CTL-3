import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // 백엔드 기본 URL (로컬 uvicorn 서버 구동 주소)
  // 에뮬레이터에서 실행할 경우 'http://10.0.2.2:8000' 등으로 조정이 필요할 수 있습니다.
  static String baseUrl = 'http://localhost:8000';

  // 현재 로그인된 사용자의 ID와 사용자 유형 (메모리 보관)
  static int? currentUserId;
  static String? currentUserType;

  // 공통 헤더 설정 (X-User-Id 헤더를 통해 백엔드에서 사용자 매핑 지원)
  static Map<String, String> _headers() {
    final Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (currentUserId != null) {
      headers['X-User-Id'] = currentUserId.toString();
    }
    return headers;
  }

  // =========================================================================
  // 1. 사용자 (Users) 관련 API
  // =========================================================================

  /// 신규 사용자 가입 (가입 완료 시 지갑도 백엔드에서 자동 생성됨)
  static Future<Map<String, dynamic>?> signUp({
    required String name,
    required String phone,
    required int birthYear,
    required String userType, // senior, guardian, merchant, admin
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/'),
        headers: _headers(),
        body: jsonEncode({
          'name': name,
          'phone': phone,
          'birth_year': birthYear,
          'user_type': userType,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        // 가입 성공 시 자동으로 로그인 처리
        currentUserId = data['user_id'];
        currentUserType = data['user_type'];
        return data;
      } else {
        print('회원가입 실패: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('회원가입 통신 에러: $e');
      return null;
    }
  }

  /// 전화번호를 이용한 로그인 시도 및 세션 갱신
  static Future<Map<String, dynamic>?> loginWithPhone(String phone) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/phone/$phone'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        currentUserId = data['user_id'];
        currentUserType = data['user_type'];
        return data;
      } else {
        print('로그인 실패: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('로그인 통신 에러: $e');
      return null;
    }
  }

  /// 현재 로그인한 유저 세션 정보 해제
  static void logout() {
    currentUserId = null;
    currentUserType = null;
  }

  // =========================================================================
  // 2. 미션 (Missions) 관련 API
  // =========================================================================

  /// 미션 목록 조회 (카테고리/난이도 필터 가능)
  static Future<List<dynamic>> getMissions({String? category, String? difficulty}) async {
    try {
      String query = '';
      if (category != null || difficulty != null) {
        final params = <String>[];
        if (category != null) params.add('category=$category');
        if (difficulty != null) params.add('difficulty=$difficulty');
        query = '?' + params.join('&');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/missions/$query'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      } else {
        print('미션 목록 로드 실패: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('미션 목록 조회 에러: $e');
      return [];
    }
  }

  /// 특정 미션의 상세 정보 및 수행 단계(steps) 목록 전체 조회
  static Future<Map<String, dynamic>?> getMissionDetail(int missionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/missions/$missionId'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      } else {
        print('미션 상세 조회 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('미션 상세 조회 에러: $e');
      return null;
    }
  }

  // =========================================================================
  // 3. 미션 로그 (Logs) 관련 API
  // =========================================================================

  /// 미션 시작/진행상황 로그 생성 (상태: 진행 중, 성공, 실패)
  /// 미션이 성공("성공")하면 백엔드에서 포인트가 지갑에 자동 입금됩니다.
  static Future<Map<String, dynamic>?> saveMissionLog({
    required int missionId,
    required String status, // 진행 중, 성공, 실패
    int score = 0,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logs/'),
        headers: _headers(),
        body: jsonEncode({
          'mission_id': missionId,
          'status': status,
          'score': score,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      } else {
        print('미션 로그 생성 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('미션 로그 기록 에러: $e');
      return null;
    }
  }

  /// 특정 사용자의 미션 진행 이력 전체 목록 조회
  static Future<List<dynamic>> getUserMissionLogs(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/logs/user/$userId'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      } else {
        print('유저 미션 로그 로드 실패: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('유저 미션 로그 조회 에러: $e');
      return [];
    }
  }

  // =========================================================================
  // 4. 지갑 및 포인트 (Wallets & Transactions) 관련 API
  // =========================================================================

  /// 내 지갑 정보 및 포인트 잔액 조회
  static Future<Map<String, dynamic>?> getMyWallet() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/wallets/me'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      } else {
        print('내 지갑 조회 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('내 지갑 조회 에러: $e');
      return null;
    }
  }

  /// 내 포인트 전체 입출금 거래 내역 조회
  static Future<List<dynamic>> getMyPointTransactions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/wallets/me/transactions'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      } else {
        print('거래 내역 조회 실패: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('거래 내역 조회 에러: $e');
      return [];
    }
  }

  // =========================================================================
  // 5. 가맹점 및 결제 (Merchants & Payments) 관련 API
  // =========================================================================

  /// 전체 상점(가맹점) 목록 조회
  static Future<List<dynamic>> getMerchants() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/merchants/'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      } else {
        print('가맹점 목록 조회 실패: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('가맹점 목록 조회 에러: $e');
      return [];
    }
  }

  /// 포인트 결제 처리 (차감액, 대상 가맹점)
  static Future<Map<String, dynamic>?> payAtMerchant({
    required int merchantId,
    required int amount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payments/'),
        headers: _headers(),
        body: jsonEncode({
          'merchant_id': merchantId,
          'amount': amount,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      } else {
        final errorMsg = jsonDecode(utf8.decode(response.bodyBytes))['detail'] ?? '결제 처리 실패';
        print('결제 오류: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('결제 처리 에러: $e');
      rethrow;
    }
  }

  /// 내 포인트 결제 히스토리 조회
  static Future<List<dynamic>> getMyPaymentHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/payments/me'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      } else {
        print('결제 내역 조회 실패: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('결제 내역 조회 에러: $e');
      return [];
    }
  }

  // =========================================================================
  // 6. 보호자 연결 (Guardians) 관련 API
  // =========================================================================

  /// 보호자 권한으로 특정 시니어 연결 등록
  static Future<Map<String, dynamic>?> linkSenior({
    required int seniorUserId,
    String? relation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/guardians/link'),
        headers: _headers(),
        body: jsonEncode({
          'senior_user_id': seniorUserId,
          'relation': relation,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      } else {
        print('시니어 연결 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('시니어 연결 에러: $e');
      return null;
    }
  }

  /// 보호자가 관리 중인 시니어 정보 목록 및 미션 수행률/잔액 요약 데이터 조회
  static Future<List<dynamic>> getMySeniors() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/guardians/my-seniors'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      } else {
        print('등록한 시니어 목록 로드 실패: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('등록한 시니어 목록 조회 에러: $e');
      return [];
    }
  }

  // =========================================================================
  // 7. 터치 오작동 에러 로그 (Errors) 관련 API
  // =========================================================================

  /// 연습 미션 도중 터치 실수 내역 수집
  static Future<Map<String, dynamic>?> logTouchError({
    required int missionId,
    required int stepId,
    String? wrongAction,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/errors/'),
        headers: _headers(),
        body: jsonEncode({
          'mission_id': missionId,
          'step_id': stepId,
          'wrong_action': wrongAction,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      } else {
        print('터치 오류 전송 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('터치 오류 전송 에러: $e');
      return null;
    }
  }
}
