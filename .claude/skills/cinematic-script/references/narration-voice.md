# Giọng người kể

## 1. Viết để nói, không phải để đọc
- Câu dài ngắn xen kẽ. Trung bình 12–18 từ/câu, nhưng phải có câu 3 từ và câu 30 từ.
- Viết tắt như nói: *he's, didn't, wasn't, that's*.
- Mỗi câu một ý. Đọc to được trong một hơi.
- Chọn động từ cụ thể thay vì tính từ: "he welds it shut from the inside" > "he did something incredibly bold".
- Thì hiện tại cho cảnh hành động (beat 1, 5, 6). Thì quá khứ cho bối cảnh.

## 2. Chi tiết cụ thể = giống người
AI viết khái quát, người kể giỏi viết **đồ vật, con số, giác quan**:
| Khái quát (AI) | Cụ thể (người) |
|---|---|
| "They celebrated inside the vault." | "They set up a folding picnic table… foie gras, baguettes, cheese, and bottles of red wine." |
| "The work was difficult." | "Some of them stood waist-deep in human waste for 6 hours at a stretch." |
| "He was a normal man." | "He gives sweets to the children who refuse to sit still." |
Mỗi beat cần ít nhất 1 chi tiết loại này, lấy từ fact-sheet.

## 3. Người kể có mặt (kiểu LEMMiNO / Barely Sociable)
- Được nói "I": "I've read the medical reports and this is what it says." Tạo uy tín.
- Được có ý kiến, được hài hước nhẹ: "So just in case the Galactic Empire had nothing to do with the death of the hikers…"
- Được nói thẳng với người xem: "Now, take a look at this photo."
- Phân biệt rõ: **sự thật** / **người ta đồn** / **tôi nghĩ**.
- Liều lượng: 2–5 lần mỗi video. Đừng biến thành vlog.

## 4. Giải thích lồng trong chuyện (kiểu *The Big Short*)
Khi cần giải thích cơ chế (khóa thời gian, séc, hạ thân nhiệt):
1. Dừng chuyện ở một khoảnh khắc treo ("…the bank's engineers had made one small decision.").
2. Mở bằng câu dẫn: "To understand why…, you need to understand…" (Lume dùng đúng câu này).
3. Giải thích bằng **so sánh đời thường** + con số, tối đa 60–90 giây.
4. Quay lại chuyện bằng "But" hoặc một câu lật.

## 5. Sự thật vs tái dựng
Kênh AI hay bịa: tên cảnh sát, lời thoại bộ đàm, nhóm 6 người mặc đồ chiến thuật… Không làm vậy.
- Được phép: mô tả bối cảnh có căn cứ (thời tiết, kiến trúc, đồ vật trong biên bản), suy luận có đánh dấu ("They would have…", "It's likely that…").
- Không được: bịa tên người, bịa câu nói trong ngoặc kép, bịa sự kiện.
- Khi tái dựng một cảnh không ai chứng kiến, nói rõ: "Nobody knows exactly what was said in that room. But we know what happened next."
- Trong `script.md`, gắn `[RECON]` cho các đoạn này để người duyệt kiểm tra.

## 6. Danh sách cấm (dấu hiệu văn AI)
`scripts/lint_script.py` tự bắt các cụm này.
- Mở bài sáo: *In a world where · Throughout history · Since the dawn of time · Imagine a world · Picture this*
- Từ AI: *delve · tapestry · testament to · a symphony of · realm · intricate · unwavering · indomitable · pivotal · navigate the complexities · embark on a journey · unravel*
- Câu sáo kịch tính: *little did they know · fate had other plans · what happened next will shock you · but here's the thing · the rest is history · and so it began*
- Kết bài triết lý: *a reminder that… · stands as a testament · the human spirit · echoes through history · only time will tell*
- Thói quen: luôn liệt kê đúng 3 ý; mỗi đoạn kết bằng một câu "sâu sắc"; lạm dụng gạch ngang (—); câu hỏi tu từ liên tiếp.
- Ví dụ xấu thật: Eclesso kết Alcatraz bằng "no prison is eternal when ingenuity and willpower meet". Kiểu câu này làm người xem nhận ra ngay là AI.

## 7. Đánh dấu cho TTS
- Ngắt dài (đổi cảnh): dòng trống + `[PAUSE]`.
- Nhấn mạnh: *in nghiêng* một từ, tối đa 1 từ mỗi câu.
- Số viết bằng chữ khi đọc dễ nhầm ("8 m" → "eight meters"). Năm giữ nguyên số.
- Tên riêng khó đọc: thêm phiên âm trong ngoặc vuông lần đầu: Spaggiari [spa-JAR-ee].
