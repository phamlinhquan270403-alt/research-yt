---
name: cinematic-script
description: Viết kịch bản YouTube long-form (8–20 phút, tiếng Anh, faceless, giọng đọc) kể chuyện có thật như một bộ phim rồi giải thích điều gì đã xảy ra. Dùng khi người dùng muốn viết/sửa kịch bản, beat sheet, hook, twist, lời dẫn cho video kể chuyện (sinh tồn, vượt ngục, gián điệp, heist/lừa đảo, bí ẩn, thảm họa), hoặc chấm điểm một kịch bản có sẵn.
---

# Cinematic script

Mục tiêu: một kịch bản **người thật kể**, có **nhịp phim**, **đúng sự thật**, và người xem không bấm thoát.
Kịch bản viết bằng **tiếng Anh** (khán giả Mỹ). Trao đổi với người dùng bằng tiếng Việt.

## Quy trình (làm đủ 7 bước, theo thứ tự)

### 1. Chốt đầu vào
Hỏi hoặc tự suy ra: chủ đề, thể loại (survival / escape / spy / heist / mystery / disaster), độ dài đích (mặc định 14 phút ≈ 2.100 từ ở 150 từ/phút), khán giả (Mỹ, không chuyên).

### 2. Nghiên cứu → `fact-sheet`
Trước khi viết một chữ kịch bản, lập bảng sự thật:
| # | Sự thật | Nguồn (link/sách/hồ sơ) | Độ chắc: ✅ chắc / ⚠️ tranh cãi / ❓ truyền thuyết |
- Ưu tiên nguồn gốc: hồ sơ tòa án, FBI/CIA giải mật, báo cùng thời, sách nghiên cứu.
- Ghi riêng **chi tiết cụ thể đắt giá** (đồ vật, con số, câu nói thật, thời tiết, giờ giấc): đây là nguyên liệu để kịch bản "giống người".
- Ghi riêng **các điểm tranh cãi**: thường chính là twist.
- Không bịa tên, lời thoại, nhân vật phụ. Xem `references/narration-voice.md` mục "Sự thật vs tái dựng".

### 3. Tìm câu chuyện (story spine)
Trả lời 6 câu, mỗi câu 1 dòng:
1. Nhân vật chính là ai, người xem thấy gì ở họ trong 10 giây đầu?
2. Họ muốn gì? Cái gì chặn họ?
3. Hệ thống/đối thủ tự tin vì điều gì? (lỗ hổng nằm ở đâu)
4. Khoảnh khắc căng nhất là gì? → dùng cho hook.
5. Twist / lật ngược là gì? (thường nằm ở điểm tranh cãi hoặc hậu truyện)
6. **Người xem đã biết kết chưa?** Nếu rồi → đổi câu hỏi trung tâm từ "có thành công không" sang "làm sao / cái giá là gì / ai đứng sau" (`references/structure.md`).

### 4. Beat sheet
Dùng khung lõi trong `references/structure.md` + module thể loại trong `references/genres.md`.
Xuất bảng: | Beat | % | phút | nội dung | câu hỏi mở (open loop) | câu hỏi được trả lời |
Kiểm tra: mỗi 60–90 giây có ít nhất một câu hỏi mới được mở.

### 5. Viết lời dẫn
Đọc trước khi viết:
- Hook: chọn 1 trong 14 kiểu ở `references/hooks-library.md`, viết 2 phương án hook khác kiểu, chọn cái mạnh hơn và nói vì sao.
- Giọng: `references/narration-voice.md` + chữ ký giọng của kênh ở cuối `references/voices.md`.
- Nhịp nói: `references/podcast-rhythm.md` (giai thoại ↔ suy ngẫm, văn nói, nói ra câu hỏi người xem).
- Kỹ thuật từng đoạn: `references/storytelling-craft.md` (cảnh vs tóm tắt, chi tiết đắt giá, thang tiết lộ, căng–chùng).
- Twist: `references/hooks-and-twists.md`. Định dạng theo `templates/script-template.md`:
- Mỗi beat có dòng `[VISUAL: ...]` gợi ý hình (để làm shot list / prompt ảnh sau).
- Câu nào dựa trên dữ kiện thì gắn `[F#]` trỏ về fact-sheet. Đoạn tái dựng không có nguồn thì gắn `[RECON]` và phải được báo cho người xem bằng lời ("We don't know exactly what was said. But...").

### 6. Tự chấm
1. Chạy `python .claude/skills/cinematic-script/scripts/lint_script.py <file>`: bắt cụm từ văn AI, câu quá dài, nhịp câu đều đều, thiếu câu hỏi mở. Sửa đến khi không còn lỗi ĐỎ.
2. Đi qua `references/checklist.md`, ghi điểm từng mục.

### 7. Giao
Lưu vào thư mục người dùng chỉ định (mặc định `G:/research niches/scripts/<slug>/`): `fact-sheet.md`, `beats.md`, `script.md`, kèm điểm checklist và kết quả lint. Báo lại: thời lượng ước tính, 3 tiêu đề gợi ý, điểm yếu còn lại.

## Nguyên tắc không được phá
- **Sự thật trước, kịch tính sau.** Không bịa để tăng kịch tính. Kịch tính đến từ cách sắp xếp và chi tiết thật.
- **Người kể có mặt:** có ý kiến, có giọng, đôi khi nói thẳng với người xem (xem LEMMiNO trong `references/learned-from-youtube.md`).
- **Không dạy cách phạm tội:** giải thích vì sao vụ việc xảy ra / lỗ hổng là gì, không viết hướng dẫn từng bước làm lại.
- **Bạo lực, cái chết:** kể gián tiếp, không mô tả máu me (giữ quảng cáo).

## Tài liệu tham khảo
- `references/structure.md`: khung lõi, nhịp câu hỏi mở, chuyện đã biết kết
- `references/genres.md`: beat sheet 6 thể loại + phim để học
- `references/hooks-and-twists.md`: 8 kiểu hook cơ bản, kỹ thuật cài và trả twist
- `references/hooks-library.md`: 14 kiểu hook từ 23 video top (~330M view) + thống kê + luật chung
- `references/voices.md`: giọng kể của 6 kênh giọng người thật + 2 podcast; đề xuất chữ ký giọng
- `references/podcast-rhythm.md`: nhịp nói học từ This American Life, Darknet Diaries
- `references/storytelling-craft.md`: 14 kỹ thuật kể chuyện phi hư cấu
- `references/narration-voice.md`: giọng người kể, danh sách cấm, giải thích lồng trong chuyện, sự thật vs tái dựng
- `references/learned-from-youtube.md`: phân tích 5 video thật (Lume, LEMMiNO, Barely Sociable, Eclesso)
- `references/film-study.md`: học gì từ từng phim + mẫu phân tích phim mới
- `references/films/*.md`: 6 phim đã phân tích sâu. Ở bước 4, đọc file phim ứng với thể loại đang viết (heist → catch-me-if-you-can, spy → operation-mincemeat, survival → apollo-13, escape → escape-from-alcatraz; twist → the-prestige; cần giải thích cơ chế → the-big-short)
- `references/checklist.md`: chấm điểm trước khi giao
