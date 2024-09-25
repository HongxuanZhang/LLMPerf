export OPENAI_API_KEY="random"
export OPENAI_API_BASE="http://localhost:46221/v1/chat/completions"

declare -i concurrent_requests=${1:-1}
declare -i mean_input_tokens=${2:-550}
store_dir=${3:-"GPU1"}

total_requests=$(( 4 * concurrent_requests ))

echo "Total requests: $total_requests"
echo "Concurrent requests: $concurrent_requests"
echo "---start---"

# 输出文件名
output_file="result_outputs/${store_dir}/requests_${concurrent_requests}_tokens_${mean_input_tokens}.txt"

# 打印组合的参数
echo "Running with Concurrent Requests: $concurrent_requests, Mean Input Tokens: $mean_input_tokens"
echo "Output will be saved to: $output_file"

# 执行 Python 脚本并重定向输出
python3 token_benchmark_ray.py \
--model "llama2-7b-chat" \
--mean-input-tokens $mean_input_tokens \
--stddev-input-tokens 150 \
--mean-output-tokens 150 \
--stddev-output-tokens 10 \
--max-num-completed-requests $total_requests \
--timeout 6000 \
--num-concurrent-requests $concurrent_requests \
--results-dir "result_outputs" \
--llm-api openai \
--additional-sampling-params '{}' \
> "$output_file" 2>&1  # 重定向输出和错误

echo "Completed with Concurrent Requests: $concurrent_requests, Mean Input Tokens: $mean_input_tokens"