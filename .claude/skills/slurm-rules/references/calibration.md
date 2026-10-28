# Resource calibration

Starting points measured on one Slurm cluster with A100, H100 and H200 GPUs. Scale by input size, and replace rows with your own measurements as runs complete (SKILL.md, "New workload types").
~27B model inference: H100 ≈ H200 ≈ 2.3× A100. Decode-bound jobs do not get faster on a faster GPU.
Terms: prompt = one model request; guided MCQ = multiple choice answered with guided decoding.

| Workload | Measured | GPU | --mem / --cpus |
|---|---|---|---|
| ~27B LLM / VLM text-only inference (vLLM) | 1–3k prompts: 8–30 min | A100 / H200 | 80G / 16 |
| ~27B LLM long reasoning (4k-token budget) + guided answer | ~75 prompts/min | H200 | 80G / 16 |
| ~27B VLM guided MCQ (vLLM), 8 images per prompt | 7.5k prompts: ~27 min H200, ~18 min H100 | H100 / H200 | 80G / 16 |
| ~27B VLM guided MCQ (vLLM), 24 images per prompt | 7.5k prompts: 2h20 A100, 1h01 H200 | A100 / H200 | 80G / 16 |
| ~27B VLM HF `generate` batch-1, ~9 images per prompt, hidden-state dump | 1.3k prompts: 15 min H100, 25 min A100; MaxRSS 61G | H100 / A100 | 96G / 16 |
| ~27B VLM HF batch-1 forwards with little work per forward | ~34k forwards/h H100; GPU util 26–53%, cancelled for low utilization at 2 h | H100 | 48G / 16; batch forwards or keep tasks < 2 h |
| ~8B VLM MCQ benchmark eval, 8 images per prompt | 1.3k prompts: 1h22 A100; MaxRSS 21G | A100 | 64G / 16 |
| ~4B VLM captioning (vLLM, 4 images, 32 tokens) | ~20 prompts/s | H100 | 64G / 16 |
| ~4B VLM captioning (vLLM) with in-job video decode | 16–25 windows/s; MaxRSS ~100G | H100 / A100 | 128G / 16 |
| ~4B VLM HF batch-1 MCQ, 8 images per prompt | 7.5k forwards: 19 min H100 | H100 / A100 | 64G / 16 |
| ~2B VLM HF batch-1 + hidden-state dump | 0.4–0.9 s per prompt at 1k–9k tokens | A100 | 32G / 8 (48G with all layers) |
| Video decode + vision-encoder features | ~1.7 clips/s (60-frame clips), decode-bound | A100 / H200 | 96G / 16 |
| Linear heads / L-BFGS fits on cached features (~20k rows, ≤5k dims) | seconds to minutes per fit | H100 / H200 | 32G / 8 |
| CPU frame decode (cv2 seek, 8 frames per sample) | ~165 samples/min | none | 32G / 16 |
| CPU frame decode (cv2 seek, ~20 frames per sample, 1080p downscaled, PNG) | ~45 samples/min; MaxRSS above 32G | none | 48G / 16 |
| CPU sequential full-video decode (16 workers, JPEG) | ~40 h of video per task in 20–30 min; MaxRSS 48G | none | 64G / 16 |
| CPU ridge probes on cached features (thousands of rows × ≤5k dims) | 30 min (small grid) to 2–5.5 h (full-width eigendecompositions), BLAS-bound; MaxRSS 12G | none | 32G / 16 |
| `tar` pack + verify | ~70 MB/s per pass | none | 24G / 4 |
| CPU analysis / eval | < 15 min | none | 16G / 4 |
| External-API caller (no local model) | ~3k requests: 45 min | none | 8G / 2 |
