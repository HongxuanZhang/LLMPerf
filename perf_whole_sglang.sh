export OPENAI_API_KEY="random"
export OPENAI_API_BASE="http://localhost:46221/v1/chat/completions"

store_dir=${1:-"GPU"}

# 定义 concurrent_requests 和 mean-input-tokens 的列表
concurrent_requests_list=(1 2 4 8 16 20)
mean_input_tokens_list=(550 1000  3500)

# 遍历两个列表并组合
for concurrent_requests in "${concurrent_requests_list[@]}"; do
    for mean_input_tokens in "${mean_input_tokens_list[@]}"; do
        # 计算总请求数
        total_requests=$(( 4 * concurrent_requests ))

        output_dir="result_outputs/${store_dir}"
        output_file="${output_dir}/requests_${concurrent_requests}_tokens_${mean_input_tokens}.txt"

        if [ ! -d "$output_dir" ]; then
            echo "Directory $output_dir does not exist. Creating it now."
            mkdir -p "$output_dir"
        else
            echo "Directory $output_dir already exists."
        fi

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
    done
done

