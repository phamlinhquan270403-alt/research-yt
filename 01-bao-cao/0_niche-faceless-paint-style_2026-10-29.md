# Nghiên cứu niche YouTube faceless — thị trường Mỹ

Ngày quét: 28–29/10/2026. Dữ liệu thô + script: `reference/thi-truong-2026-10/` (không commit).

## 1. Tiêu chí

| Tiêu chí | Giá trị |
|---|---|
| Thị trường | Mỹ, tiếng Anh |
| Độ dài | 8–15 phút |
| Hình | Không người thật; không video do AI tạo hình (AI hỗ trợ edit thì được) |
| Giọng | TTS / giọng AI |
| Sản lượng | 3–5 video/tuần mỗi kênh |
| Nội dung người khác | Càng ít càng tốt; tự dựng bằng animation, motion, Remotion |
| Chuyên môn | Không cần chuyên môn sâu hay thiết bị thật; kịch bản soạn được từ Wikipedia, báo, bài khoa học |
| Mục tiêu | Bật kiếm tiền (YPP) nhanh |
| Lọc kênh | Kênh đã đăng 50–150 video dài (đã chứng minh làm đều, không phải ăn may 1 video) |

## 2. Cách làm

1. **Quét tìm kiếm** bằng `yt-dlp` (Chrome extension không kết nối): 54 cụm từ khóa, mỗi cụm 40 video đầu, lọc *năm nay + 4–20 phút + sắp theo lượt xem* → ~2.200 video (`scan1-3.json`).
2. **Tra kênh**: 123 kênh tiếng Anh có video ≥100k view. Lấy số sub, số video dài (tab Videos, không tính Shorts), ngày đăng video cũ nhất còn trên kênh, view trung vị 10 video gần nhất (`chans*.json`).
3. **Xem tiêu đề** 6 video gần nhất của từng kênh để biết họ làm gì, có mặt người/footage không, cần chuyên môn không.
4. **Lọc 50–150 video** và tính sub trung bình mỗi tháng (`sel.json`).

Chỉ số dùng:
- **med10**: view trung vị 10 video dài gần nhất — kênh còn sống không, view đều không.
- **sub/tháng**: sub ÷ số tháng từ video đầu — tốc độ tăng trưởng trung bình.
- **med10/sub**: >1 là video đang được đề xuất cho người chưa sub (dấu hiệu niche còn chỗ).

## 3. Kiếm tiền và rủi ro chính sách

- Điều kiện YPP: 1.000 sub + 4.000 giờ xem trong 12 tháng. Video 10 phút, xem trung bình ~4 phút → cần khoảng **60.000 view** dài.
- Từ 15/07/2025 YouTube đổi tên chính sách "repetitious content" thành **"inauthentic content"**: nội dung sản xuất hàng loạt, lặp lại (slideshow + giọng đọc na ná nhau) không được kiếm tiền. Đầu 2026 nhiều kênh faceless AI bị tắt kiếm tiền.
- Hệ quả cho mình: TTS vẫn được, nhưng **kịch bản phải tự viết, mỗi video có hình và cách dựng khác nhau**, không dùng một template chỉ thay chữ.
- Chủ đề băng đảng, cái chết, tội ác, thảm họa: dễ bị giới hạn quảng cáo (vàng).
- Sức khỏe: tránh lời khuyên y tế cụ thể (chính sách thông tin sai y tế).

RPM Mỹ ước tính (từ blog tổng hợp, chênh nhau nhiều, chỉ để so tương đối): tài chính $12–30 · công nghệ $10–20 · tâm lý, khoa học $8–14 · lịch sử $5–12 · giải trí, giả định $3–8.

## 4. Xu hướng chung

Hầu hết kênh mới thắng năm 2025–2026 dùng:
- **Hình vẽ tay kiểu MS Paint, que diêm, doodle**: rẻ, làm hàng loạt được, được coi là nội dung tự làm.
- **Tiêu đề dạng liệt kê**: "Every X Explained", "Your Life as Every Level of X", "What If…", "How X Actually Works", "Why X is…".
- Độ dài 8–16 phút.

## 5. Niche xếp theo độ khó (dành cho người không chuyên)

Độ khó = kịch bản (liệt kê dễ hơn kể chuyện; khoa học, tài chính phải chính xác) + hình (que diêm < bản đồ động < 3D/animation đẹp).

### 🟢 Dễ

| Niche | Tiêu đề mẫu | Nguồn kịch bản | Kênh bằng chứng |
|---|---|---|---|
| Giả định "What If" / POV | What If Everything You Touched Turned to Gold? | Không cần kiểm chứng; cần sáng tạo | [Hypothetically](https://www.youtube.com/channel/UC0L9hD7HMwWU7xuU5HRA6Iw), [Oddly Elsewhere](https://www.youtube.com/channel/UCkBWqYRvvIWm_9udfvgFWjA), [IFOLOGY](https://www.youtube.com/channel/UCv4DniMRgnBTmfFaxeMTTLA), [2 am thoughts](https://www.youtube.com/channel/UCS0C7szQGhzdBNHnDr39AEA) |
| Thần thoại "Every X Explained" | Every Greek God Explained | Wikipedia, theoi.com | [Mythological Man](https://www.youtube.com/channel/UCrdQ8oyNq_D-fHNo6yQC44g), [MythLore Unpacked](https://www.youtube.com/channel/UCJBu8PlYhslPSYpovOGGK5g) |
| Tâm lý học kiểu Paint | Every Feeling You Can't Name Explained | Wikipedia, Psychology Today | [Brainosophy](https://www.youtube.com/channel/UC6pABWB5cm6efpzCKNlys7A), [EverythingProfessor](https://www.youtube.com/channel/UCbrSe4uBIeqJweOYnJAOsrw), [PsychToons](https://www.youtube.com/channel/UC7ogBsKt4AoJBu8bObb0QiA), [Big Brain Explains](https://www.youtube.com/channel/UCZFpGiabZ9BDNhQtD5t8TAA), [Eniqma](https://www.youtube.com/channel/UCkkr2KyKWP9Q2GSOTAw7s5w) |
| Đồ ăn "Every X Explained" | Every Donut Explained | Wikipedia, trang hãng | [FooDiscover](https://www.youtube.com/channel/UCddXepURe7TTkRWrQXwwrgw) |
| Đồ công nghệ phổ thông | Every USB Port Color Explained in 8 Minutes | Wikipedia, thông số nhà sản xuất | [Byte Sized Explainer](https://www.youtube.com/channel/UCqUTa0HvxmUsmSrGJsmglPw) |
| Quân sự "How X Actually Works" | How Military Badges Actually Work | Wikipedia, trang quân đội Mỹ | [Casual Tactics](https://www.youtube.com/channel/UCjo7GpEBU5ZmY4uWzJhPUXA) |
| Top/list "kỳ lạ nhất, tệ nhất" | How to Survive Every Natural Disaster | Wikipedia, báo | [Simple Paint](https://www.youtube.com/channel/UCXbCOOoXE09V6StOp0gbTFQ), [Finest Explainer](https://www.youtube.com/channel/UC2RkPC-fzVCAdOEwc11Eesw), [Uncivil Engineer](https://www.youtube.com/channel/UCfqxnFCPcIrkCMt_LXDZtjg), [Crunchy History](https://www.youtube.com/channel/UCnNkV9ZvjGaPfk_QnfR8fDA) |

### 🟡 Trung bình

| Niche | Tiêu đề mẫu | Ghi chú | Kênh bằng chứng |
|---|---|---|---|
| Đời sống người xưa | What Did Ancient Humans Actually Do All Day? | Wikipedia + bài khoa học phổ thông | [Ink Explainer](https://www.youtube.com/channel/UCpgrEMx8diLrw7YNQ6r3uUw), [Medieval Mindset](https://www.youtube.com/channel/UCwS7tk2pxX_PZQ5NtmnHgTA), [Zenn](https://www.youtube.com/channel/UCK8TbMQGDbB94EOR3aGJo3Q), [StickTory](https://www.youtube.com/channel/UCEK374Y8TMu2DjHk0Pu4yog) |
| Lịch sử tổng hợp | The ENTIRE History of The Cold War Explained | Chiến tranh, cái chết: làm nhẹ tay | [Unknown Frequencies](https://www.youtube.com/channel/UCm1yxl_4qMbStLHpHQu6xWg), [The Scribble Scholar](https://www.youtube.com/channel/UCu6S_MpYydihE-R_MMY1y5A), [The Painful Historian](https://www.youtube.com/channel/UCz3FEPFNZtF3qANtr1_5XEA), [History Matters](https://www.youtube.com/channel/UC22BdTgxefuvUivrjesETjg) |
| Tâm lý xã hội dạng essay | Why Power Is So Addictive | Cần lập luận, không chỉ liệt kê | [The Visual Philosopher](https://www.youtube.com/channel/UCfxZMvlfb7HKebpNkBtn_FQ) |
| Doanh nghiệp "Explained Like You're 5" | Tech CEOs Who Destroyed Their Own Companies | Báo kinh doanh; RPM cao | [Money Chuck](https://www.youtube.com/channel/UCcA2aJFGGbSHVuqVp23rJlw) |
| Tiền và kinh tế | 401k Explained with Bananas | Investopedia, IRS.gov; phải đúng số; RPM cao nhất | [Primate Economics](https://www.youtube.com/channel/UC14Fb2zWTEZklONPXFbLrTQ), [Bille Finance](https://www.youtube.com/channel/UCl42jG0SdOVmXjcy4MazKvw), [LITTLE BIT BETTER](https://www.youtube.com/channel/UCmbF1cyNa6y7uNYiqYmSVJw) |
| Địa lý | Why Siberia Is Earth's Strangest Place | Cần bản đồ động (Remotion) | [Geography By Geoff](https://www.youtube.com/channel/UC7-Z34pbJ0ZAOJRmUCEz0Cg), [Coggnize](https://www.youtube.com/channel/UCYmeh6MS6sVnwN94MD0MHSw), [FactSpark](https://www.youtube.com/channel/UC5EcQrgvXsgGLR4ukxBTM8w) |

### 🟠 Khá khó

| Niche | Ghi chú | Kênh bằng chứng |
|---|---|---|
| Vũ trụ | Ảnh NASA là public domain; khoa học phải đúng | [Cosmic Lens](https://www.youtube.com/channel/UCjz1107N5-17ZQOz1g6XaOQ) |
| Đại dương, Trái Đất tiền sử | Video mẫu dài 25–40 phút, phải rút xuống; cần hình sinh vật | [BeyondTheBlue](https://www.youtube.com/channel/UCy6-V0dTuvNB_uFXpE5K5uQ), [Mr. Science](https://www.youtube.com/channel/UCOM1gIM4Q_-OniEdhUvHEkA) |
| Sự kiện "Mapped" (vụ án, thảm họa) | Bản đồ động + chủ đề nhạy cảm | [Uncovering](https://www.youtube.com/channel/UCrsm1dqSALPG5BCCiI0Ebug) |
| Lịch sử quân sự animation đẹp | Animation tốn công | [Mitsi Studio](https://www.youtube.com/channel/UCuXCgyOCMXic7j0_wghXnRA) |

## 6. Kênh qua bộ lọc 50–150 video

Faceless, tiếng Anh, không cần chuyên môn sâu, đã đăng 50–150 video dài. Sắp theo sub/tháng.

| Kênh | Niche | Độ khó | Video đầu | Số video | Sub | Sub/tháng | med10 |
|---|---|---|---|---|---|---|---|
| [EverythingProfessor](https://www.youtube.com/channel/UCbrSe4uBIeqJweOYnJAOsrw) | Tâm lý, cơ thể "Every X" | 🟢 | 05/2025 | 99 | 695k | 38,6k | 95k |
| [Simple Paint](https://www.youtube.com/channel/UCXbCOOoXE09V6StOp0gbTFQ) | Top/list | 🟢 | 03/2025 | 136 | 541k | 28,5k | 213k |
| [LITTLE BIT BETTER](https://www.youtube.com/channel/UCmbF1cyNa6y7uNYiqYmSVJw) | Tiền, tự phát triển | 🟡 | 09/2022 | 118 | 1,4M | 28,6k | 485k |
| [Psychology Simplified](https://www.youtube.com/channel/UCHacVMLp7bHDC7e4eoPi9Dw) | Tâm lý | 🟢 | 11/2025 | 142 | 274k | 24,9k | **5,8k** ⚠️ đang tụt |
| [PsychToons](https://www.youtube.com/channel/UC7ogBsKt4AoJBu8bObb0QiA) | Tâm lý | 🟢 | 01/2026 | 138 | 209k | 20,9k | 64k |
| [Medieval Mindset](https://www.youtube.com/channel/UCwS7tk2pxX_PZQ5NtmnHgTA) | Đời sống người xưa | 🟡 | 01/2025 | 53 | 271k | 12,9k | 490k |
| [BeyondTheBlue](https://www.youtube.com/channel/UCy6-V0dTuvNB_uFXpE5K5uQ) | Đại dương | 🟠 | 01/2025 | 101 | 255k | 12,1k | 395k |
| [The Scribble Scholar](https://www.youtube.com/channel/UCu6S_MpYydihE-R_MMY1y5A) | Lịch sử | 🟡 | 11/2025 | 112 | 109k | 9,1k | 54k |
| [Coggnize](https://www.youtube.com/channel/UCYmeh6MS6sVnwN94MD0MHSw) | Địa lý | 🟡 | 10/2021 | 135 | 546k | 9,0k | 204k |
| [Uncovering](https://www.youtube.com/channel/UCrsm1dqSALPG5BCCiI0Ebug) | Sự kiện "Mapped" | 🟠 | 12/2021 | 79 | 386k | 6,7k | 279k |
| [StickTory](https://www.youtube.com/channel/UCEK374Y8TMu2DjHk0Pu4yog) | Đời sống người xưa | 🟡 | 07/2024 | 50 | 147k | 5,3k | **6,2k** ⚠️ đang tụt |
| [The Visual Philosopher](https://www.youtube.com/channel/UCfxZMvlfb7HKebpNkBtn_FQ) | Tâm lý xã hội essay | 🟡 | 03/2026 | 59 | 36,5k | 5,2k | 84k |
| [FooDiscover](https://www.youtube.com/channel/UCddXepURe7TTkRWrQXwwrgw) | Đồ ăn "Every X" | 🟢 | 07/2025 | 54 | 75k | 5,0k | 33k |
| [The Painful Historian](https://www.youtube.com/channel/UCz3FEPFNZtF3qANtr1_5XEA) | Lịch sử (video 20–100 phút) | 🟡 | 10/2025 | 144 | 55k | 4,6k | 49k |
| [2 am thoughts](https://www.youtube.com/channel/UCS0C7szQGhzdBNHnDr39AEA) | What If quân sự | 🟢 | 08/2025 | 59 | 46k | 3,3k | 60k |
| [Bille Finance](https://www.youtube.com/channel/UCl42jG0SdOVmXjcy4MazKvw) | Tài chính cá nhân | 🟡 | 02/2026 | 77 | 27k | 3,0k | 9,3k |
| [Eniqma](https://www.youtube.com/channel/UCkkr2KyKWP9Q2GSOTAw7s5w) | Tâm lý | 🟢 | 03/2019 | 81 | 224k | 2,4k | 62k |
| [FactSpark](https://www.youtube.com/channel/UC5EcQrgvXsgGLR4ukxBTM8w) | Địa lý | 🟡 | 05/2020 | 93 | 180k | 2,3k | 113k |
| [Money Chuck](https://www.youtube.com/channel/UCcA2aJFGGbSHVuqVp23rJlw) | Doanh nghiệp | 🟡 | 10/2025 | 65 | 21k | 1,6k | 14k |

Nhận xét:
- **Tâm lý học** có nhiều kênh qua lọc nhất và tăng nhanh nhất ở nhóm 🟢. Nhưng Psychology Simplified (142 video trong 11 tháng, ~3 video/tuần) đang tụt view mạnh: dấu hiệu bị bão hòa hoặc bị coi là sản xuất hàng loạt. Chất lượng mỗi video quan trọng hơn số lượng.
- **Lịch sử, địa lý** tăng chậm hơn nhưng view giữ đều qua nhiều năm (Coggnize, FactSpark).
- **Thần thoại, công nghệ phổ thông, giả định** gần như không còn kênh nào trong khoảng 50–150 video: các kênh mạnh đều mới (dưới 50 video), nên chưa có bằng chứng làm đều lâu dài. Đổi lại, ít cạnh tranh từ kênh lâu năm.

Kênh mạnh nhưng **chưa đủ 50 video** (tham khảo, không qua lọc): Brainosophy (2), Primate Economics (17), Byte Sized Explainer (25), Ink Explainer (19), Unknown Frequencies (23), Hypothetically (41), Mr. Science (20), Mythological Man (34), MythLore Unpacked (35), Cosmic Lens (47).

## 7. Đã loại

| Kênh | Lý do |
|---|---|
| The Space Race, Digital Astronaut | Bám tin tức SpaceX/NASA, tự đi quay phóng tên lửa |
| Tech With Diego, Caleb Writes Code, Reysu | Cần chuyên môn hoặc trải nghiệm thật |
| Think Science | Lời khuyên sức khỏe kiểu "reverse fatty liver in 10 days" — rủi ro chính sách y tế |
| KinoMakesSense, Cosmic Lore, Crog, Lessons Of | Dùng footage game, phim hoạt hình của người khác |
| UnderTheHeadline | Tin thời sự, phải chạy theo tin |
| The Life Outline | Toàn cấp bậc băng đảng — dễ bị giới hạn quảng cáo |
| Tyler Vitelli, Speeed, Cleo Abram, RobWords, Elephants in Rooms | Có người thật hoặc quay ngoài đời |
| Mystery Docs, ImaginFilm, Sunlike study, AniDoc | Tiếng Hindi / thị trường Ấn |
| The Animal Dude, POV Tales, football for dummies, ago. | View quá thấp (med10 < 5k) |

## 8. Đề xuất

1. **Làm trước:** tâm lý học kiểu Paint (nhiều kênh qua lọc, tăng nhanh nhất) hoặc thần thoại "Every X Explained" (ít cạnh tranh lâu năm). Kịch bản dạng liệt kê nên agent soạn được từ Wikipedia; hình que diêm làm hàng loạt được.
2. **Sau khi quen quy trình:** doanh nghiệp hoặc tiền và kinh tế (RPM cao), hoặc địa lý (bền).
3. **Tránh** chạy 3+ video/tuần bằng một template cố định (bài học Psychology Simplified).

## 9. Dữ liệu cần cho nghiên cứu thị trường YouTube

### Cấp niche — có nên vào không
| Dữ liệu | Để trả lời | Lấy ở đâu |
|---|---|---|
| View của video top trong 30–90 ngày gần nhất | Còn nhu cầu không | YouTube search (lọc ngày), yt-dlp, YouTube Data API |
| Số kênh mới (<12 tháng) đạt >10k sub | Người mới còn chen vào được không | Như trên + ngày mở kênh |
| Tỷ lệ view video / sub kênh (outlier) | Thuật toán có đẩy cho người chưa sub không | Tự tính |
| RPM/CPM theo chủ đề | Mỗi view đáng bao nhiêu | Blog tổng hợp (chỉ tham khảo); chính xác nhất là Studio của kênh mình |
| Lượng tìm kiếm, mùa vụ | Chủ đề lâu dài hay nhất thời | Google Trends (chọn "YouTube Search"), vidIQ/TubeBuddy |
| Độ trùng tiêu đề | Đã bão hòa chưa | Đọc 50–100 tiêu đề top |
| Thân thiện quảng cáo | Có bị vàng không | Chính sách quảng cáo YouTube |

### Cấp kênh đối thủ — họ làm thế nào
| Dữ liệu | Ý nghĩa |
|---|---|
| Ngày mở kênh, số video, tần suất đăng | Tốc độ và sức sản xuất |
| Sub, sub/tháng, đường tăng sub theo thời gian | Tăng đều hay nhờ 1 video (Social Blade có lịch sử) |
| View trung vị 10 và 30 video gần nhất | Kênh đang lên hay đang tụt |
| Đã bật kiếm tiền chưa (có quảng cáo, nút Join) | Niche này có được duyệt YPP không |
| Độ dài video, cấu trúc, phong cách hình, giọng | Công thức để học theo |
| Thumbnail và mẫu tiêu đề | Cái gì kéo CTR |
| Like/view, comment/view | Mức độ gắn kết |

### Cấp video — làm video nào
| Dữ liệu | Ý nghĩa |
|---|---|
| View/ngày kể từ khi đăng | Video đang được đẩy hay đã nguội |
| Outlier score = view ÷ view trung vị của kênh | Chủ đề nào vượt mặt bằng chung → nên làm |
| 30 giây đầu (hook) | Cách giữ người xem |
| Comment: câu hỏi, yêu cầu | Chủ đề người xem muốn mà chưa ai làm |

### Sau khi có kênh — dữ liệu thật duy nhất
YouTube Studio: CTR thumbnail, thời lượng xem trung bình, đường giữ chân, nguồn lưu lượng, quốc gia người xem, RPM thật. Mọi số ở trên chỉ là ước tính trước khi có dữ liệu này.

## 10. Hạn chế

- Chưa xác minh kênh nào đã bật kiếm tiền.
- Ngày mở kênh lấy theo video cũ nhất còn trên kênh; nếu kênh xóa video cũ thì tuổi thật lớn hơn.
- Chưa xem từng kênh có dùng AI tạo hình không.
- Chưa có lịch sử tăng sub theo thời gian (Social Blade), sub/tháng là trung bình.
- Kết quả tìm kiếm YouTube phụ thuộc thuật toán và vị trí (máy quét ở Việt Nam, không phải Mỹ).
- RPM lấy từ blog, không phải dữ liệu đã kiểm chứng.

## Nguồn

- [OpusClip – Faceless niches 2026](https://www.opus.pro/blog/faceless-youtube-niches-2026)
- [OutlierKit – Most profitable niches (CPM)](https://outlierkit.com/blog/most-profitable-youtube-niches)
- [Fluxnote – Faceless niches USA 2026](https://fluxnote.io/guides/best-faceless-niches-usa-2026)
- [Rookcast – Faceless niches by RPM](https://rookcast.com/guides/faceless-youtube-niches)
- [Frameloop – Faceless YouTube statistics 2026](https://frameloop.ai/blog/faceless-youtube-statistics-2026)
- [TechCrunch – YouTube crackdown on mass-produced content](https://techcrunch.com/2025/07/09/youtube-prepares-crackdown-on-mass-produced-and-repetitive-videos-as-concern-over-ai-slop-grows)
- [Digiday – YouTube AI slop crackdown](https://digiday.com/media/youtubes-ai-slop-crackdown-has-creators-concerned-marketers-cheering)
