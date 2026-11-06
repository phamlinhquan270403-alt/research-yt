# Niche "chuyện thật kể như phim": so sánh và cách áp dụng

Ngày quét: 06/11/2026. Dữ liệu: `02-data/cinematic-niche-scan-2026-11-06.json` (script: `03-scripts/cine_scan.py`).
Cách đo: mỗi niche 2 từ khóa, lấy top 10 video **năm 2026**, dài 4–20 phút, sắp theo view → khoảng 20 video/niche.
- **Trung vị**: video top năm nay thường đạt bao nhiêu.
- **P25**: video yếu trong top. Nếu P25 cao, nhiều kênh khác nhau cùng ăn được, không chỉ một kênh lớn.

Hạn chế: quét từ IP Việt Nam nên kết quả lẫn video Ấn Độ và K-pop. Mình đã loại nhiễu bằng tay. Đây là tín hiệu nhu cầu, không phải bằng chứng kiếm tiền.

## 1. Bảng so sánh

| # | Niche | Thể loại phim tương ứng | Trung vị / P25 2026 | Chất phim sẵn có | Không cần hiểu Mỹ | Hình | An toàn quảng cáo | Đánh giá |
|---|---|---|---|---|---|---|---|---|
| 1 | **Sinh tồn có thật** | 127 Hours, Society of the Snow, Cast Away | 769k / **530k** | Rất cao: hành trình anh hùng có sẵn | ✅ | AI + ảnh thật | ✅ Cao (kết truyền cảm hứng) | ⭐ **Đề xuất 1** |
| 2 | **Vượt ngục / đào thoát** | The Great Escape, Escape from Alcatraz, Shawshank | 1,7M / **700k** | Rất cao: kế hoạch → thực hiện → suýt lộ → tự do | ✅ | AI + sơ đồ | ✅ Khá | ⭐ **Đề xuất 2** |
| 3 | **Gián điệp & chiến dịch đánh lừa** (lịch sử) | Bridge of Spies, Argo, Operation Mincemeat | 1,25M / 263k | Rất cao: twist là bản chất của thể loại | ✅ | **Hồ sơ giải mật CIA/FBI (public domain)** + AI | ✅ Khá | ⭐ **Đề xuất 3** |
| 4 | Lừa đảo & trộm lớn | Ocean's Eleven, Catch Me If You Can | 587k / **38k** | Rất cao | ✅ | AI (như Lume) | ✅ Khá | Mạnh nhưng phân hóa: người thắng ăn hết |
| 5 | Bí ẩn đã có lời giải | Phim trinh thám | 1,34M / 770k | Cao: màn lật mở ở cuối | ✅ | AI + ảnh thật | ✅ | Tốt, nhưng dễ trượt sang giả khoa học |
| 6 | Điều tra tai nạn máy bay | Sully, Flight | 1,7M / 295k | Cao: phá án từng bước | ✅ | **3D / Three.js** | ⚠️ Có người chết | Đối thủ chuyên môn mạnh, khán giả rất khó tính |
| 7 | Thảm họa: những giờ cuối | Titanic, Chernobyl, Deepwater Horizon | 1,17M / 500k | Cao: đồng hồ đếm ngược | ✅ | AI + ảnh thật | ⚠️ Có người chết | Báo lớn cũng làm (4/19 video là của media) |
| 8 | Công ty lên đỉnh rồi sụp | The Social Network, BlackBerry, Tetris | 1,5M / 673k | Trung bình | ❌ Cần hiểu thương hiệu | AI + ảnh | ✅ | Hợp nếu chọn thương hiệu toàn cầu (Nokia, Kodak) |
| 9 | Cuộc đua phát minh | The Imitation Game, Oppenheimer | 100k / **1,6k** | Cao | ✅ | 3D | ✅ | Primal Space ăn gần hết, kênh khác flop |
| 10 | Chiến dịch quân sự | 7 Days in Entebbe | 1,24M / 522k | Cao | ✅ | AI | ⚠️ Bạo lực, chạy theo tin chiến sự | Chỉ làm vụ lịch sử, tránh thời sự |
| 11 | Buôn lậu / cartel | Narcos, Blow | 140k / 25k | Cao | ✅ | AI | ❌ Ma túy, bạo lực | Loại |

Ví dụ kênh thắng: sinh tồn (Eclesso "72 Days in the Andes" 1,1M); vượt ngục (Law By Mike "The Craziest Prison Escapes Ever" 2,9M; Eclesso "Escape from Alcatraz" 2,5M); gián điệp (Primal Space "How The CIA Hacked Russia" 2,5M); lừa đảo (Lume, trung vị 10 video gần nhất 233k); bí ẩn (The Infographics Show "MH370's Last Hunt" 2,7M).

## 2. Biến thể đáng thử (ngách hẹp hơn, ít người làm hơn)

**Sinh tồn**
- *"The Decision That Saved Them"*: mỗi video xoay quanh một quyết định sống còn. Twist nằm ở quyết định đó.
- Sinh tồn sau tai nạn máy bay (kết hợp 3D máy bay với chuyện sinh tồn).
- Bị bỏ lại: lạc trên đảo, trên biển, trong rừng hàng tháng.

**Vượt ngục / đào thoát**
- **Vượt Bức tường Berlin**: khinh khí cầu tự chế, đường hầm, dây cáp trượt. Chuyện có thật, nhiều ảnh lưu trữ, ít kênh làm sâu.
- Tù binh Thế chiến 2 vượt trại (Great Escape, Colditz).
- Trốn khỏi nơi "không thể trốn": Alcatraz, đảo Quỷ.

**Gián điệp**
- **Chiến dịch đánh lừa trong chiến tranh**: Operation Mincemeat (xác chết mang tài liệu giả), Ghost Army (đội quân bơm hơi). Mỗi chuyện là một cú lừa khổng lồ, đúng chất twist.
- Điệp viên hai mang thời Chiến tranh Lạnh: ai phản bội ai.
- Đánh cắp công nghệ: bí mật bom nguyên tử, Concorde và tàu Tu-144.

**Lai ghép (một kênh, nhiều thể loại)**
- Lời hứa của kênh: *"Real stories that play like movies"*. Mỗi video mang một thể loại phim: heist, escape, spy, survival.
- Eclesso và Lume đều khá rộng mà vẫn thắng. Nhưng kênh quá rộng thì thuật toán khó tìm đúng khán giả. Xem chiến lược ở mục 4.

## 3. Áp dụng skill "viết kịch bản kiểu phim"

Một skill lõi dùng chung, cộng thêm một module beat sheet cho từng thể loại:

| Module | Khung beat (video 12–18 phút) | Phim để Claude học cấu trúc |
|---|---|---|
| **Lõi (mọi video)** | Hook 30 giây từ khoảnh khắc căng nhất → lùi lại kể từ đầu → cứ 60–90 giây mở một câu hỏi mới → twist ở khoảng 70% → kết + "vì sao nó xảy ra" | Tất cả bên dưới |
| Survival | Bình thường → tai họa → thử thách leo thang → điểm đáy (muốn bỏ cuộc) → quyết định then chốt → giải cứu → cái giá phải trả | 127 Hours, Society of the Snow, The Martian |
| Escape | Nhà tù "không thể trốn" → nhân vật & động cơ → kế hoạch (cài chi tiết) → chuẩn bị → suýt lộ → đêm vượt ngục → hệ quả / twist | The Great Escape, Escape from Alcatraz, Shawshank |
| Spy | Bối cảnh → nhiệm vụ → vỏ bọc → căng thẳng (ai biết gì) → lật mặt / phản bội → hệ quả lịch sử | Bridge of Spies, Argo, Tinker Tailor |
| Heist / con | Mục tiêu → kẻ chủ mưu → lỗ hổng hệ thống → kế hoạch → thực hiện → sự cố → bị bắt hay thoát → twist | Ocean's Eleven, Catch Me If You Can, Inside Man |
| Mystery | Sự việc khó hiểu → các giả thuyết → manh mối → giả thuyết sai bị loại → lời giải → điều còn bỏ ngỏ | Zodiac, Knives Out |

Phần "giải thích điều gì đã xảy ra" luôn đặt ở beat cuối: cơ chế, bài học, hệ thống đã thay đổi thế nào.

## 4. Chiến lược đề xuất

1. **Làm skill lõi trước**, sau đó thêm 3 module: survival, escape, spy.
2. **Thử 3 thể loại, mỗi thể loại 2 video** (tổng 6 video), dưới cùng lời hứa *"real stories that play like movies"*.
3. Sau 6 video, nhìn CTR và thời lượng xem để **dồn sức vào thể loại thắng**. Nếu muốn, đổi tên kênh cho hẹp lại.
4. Chọn chuyện theo luật: **ít người biết, twist mạnh, có nguồn đáng tin**. Chuyện quá nổi tiếng đã bị kênh AI cày (ví dụ Victor Lustig "bán tháp Eiffel").

## 5. Rủi ro chung

- Hình AI tái hiện sự kiện thật → bật nhãn *altered or synthetic content* khi đăng.
- Người thật: ưu tiên vụ cũ, đã có kết luận, nguồn từ tòa án, hồ sơ giải mật, báo uy tín.
- Không viết kiểu hướng dẫn: giải thích vì sao vụ việc xảy ra, không dạy cách vượt ngục hay lừa đảo.
