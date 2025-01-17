
#unset http_proxy
HTTPPROXY=$http_proxy
HTTPSPROXY=$https_proxy
unset http_proxy
unset https_proxy

#外部传入参数说明
# $1:  $XPU = gpu or cpu
#获取当前路径
cur_path=`pwd`
model_name=${PWD##*/}

echo "$model_name 模型训练阶段"

#路径配置
root_path=$cur_path/../../
code_path=$cur_path/../../models_repo/examples/lexical_analysis/
log_path=$root_path/log/$model_name/
mkdir -p $log_path
#临时环境更改
cd $root_path/models_repo

#访问RD程序
cd $code_path

DEVICE=$1
if [[ ${DEVICE} == "gpu" ]]; then
N_GPU=1
else
N_GPU=0
fi
MULTI=$2
if [[ ${MULTI} == "multi" ]]; then
N_GPU=2
fi

print_info(){
if [ $1 -ne 0 ];then
    cat ${log_path}/$2.log
    echo "exit_code: 1.0" >> ${log_path}/$2.log
else
    echo "exit_code: 0.0" >> ${log_path}/$2.log
fi
}

if [[ ${MULTI} == "single" ]]; then
    python train.py \
        --data_dir ./lexical_analysis_dataset_tiny \
        --model_save_dir ./save_dir \
        --epochs 10 \
        --batch_size 32 \
        --device ${DEVICE} >$log_path/train_${MULTI}_${DEVICE}.log 2>&1
    print_info $? train_${MULTI}_${DEVICE}
else
    python -m paddle.distributed.launch --gpus "$3" train.py \
        --data_dir ./lexical_analysis_dataset_tiny \
        --model_save_dir ./save_dir \
        --epochs 10 \
        --batch_size 32 \
        --device ${DEVICE} >$log_path/train_${MULTI}_${DEVICE}.log 2>&1
    print_info $? train_${MULTI}_${DEVICE}
fi

#set http_proxy
export http_proxy=$HTTPPROXY
export https_proxy=$HTTPSPROXY
