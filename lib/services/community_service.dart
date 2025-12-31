import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CommunityService {
  // ✅ Feed tiếng Việt (demo nội bộ)
  // Bạn có thể thay bằng API thật sau này mà UI không cần đổi.
  List<Map<String, dynamic>> _vnDemoFeed({int limit = 20}) {
    final posts = <Map<String, dynamic>>[];

    final titles = <String>[
      "Hôm nay mình thấy nhẹ lòng hơn",
      "Một bài nhạc cứu cả buổi tối",
      "Tâm trạng hơi chông chênh",
      "Cần chút năng lượng để tiếp tục",
      "Nghe nhạc và tự chữa lành",
      "Chia sẻ chút cảm xúc",
      "Một ngày bình yên hiếm hoi",
      "Đêm nay nghe gì cho ngủ ngon?",
      "Tập trung làm việc thôi!",
      "Buồn một chút rồi sẽ qua",
    ];

    final bodies = <String>[
      "Mình vừa nghe một bài rất êm, cảm giác như được ôm nhẹ. Ai có bài tương tự gợi ý mình với!",
      "Có những lúc chỉ cần đúng một giai điệu là mọi thứ dễ thở hơn. Bạn đang nghe gì?",
      "Hôm nay đầu óc hơi rối… mình chọn nhạc chill để thả trôi một chút.",
      "Mình cần nhạc có beat rõ ràng để lấy lại động lực. Bạn có playlist nào không?",
      "Nghe nhạc xong mình thấy ổn hơn nhiều. Nhớ uống nước và thở sâu nhé.",
      "Mình muốn chia sẻ bài này vì nó làm mình thấy được đồng cảm.",
      "Một buổi chiều không ồn ào, chỉ có gió và một bài nhạc nhẹ.",
      "Tối rồi, mình ưu tiên nhạc không lời/ambient để dễ ngủ hơn.",
      "Bật nhạc focus lên là vào guồng ngay. Chúc mọi người làm việc hiệu quả!",
      "Nếu bạn đang buồn, mong bạn biết rằng bạn không một mình.",
    ];

    for (var i = 0; i < limit; i++) {
      posts.add({
        "id": i + 1,
        "title": titles[i % titles.length],
        "body": bodies[i % bodies.length],
      });
    }

    return posts;
  }

  Future<List<Map<String, dynamic>>> fetchFeed() async {
    // ✅ Ưu tiên trả về tiếng Việt để đúng yêu cầu UI
    // (Bạn vẫn có thể đổi sang API thật sau)
    await Future.delayed(const Duration(milliseconds: 350));
    return _vnDemoFeed(limit: 20);
  }

  Future<void> postAnonymous({
    required String title,
    required String body,
  }) async {
    // Giữ demo post như cũ (jsonplaceholder)
    final uri = Uri.parse("https://jsonplaceholder.typicode.com/posts");
    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"title": title, "body": body, "userId": 999}),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("Post failed: ${res.statusCode} - ${res.body}");
    }
  }
}
