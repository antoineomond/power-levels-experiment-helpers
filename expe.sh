set -e

# usage: expe.sh <config.toml> [nomon]
CONFIG=$1
cfg() { yq -p toml -o yaml "$1" "$CONFIG"; }

# parameters
EXPE_NAME=$(cfg .experiment.name)
RESULTS_DIR=$(cfg .experiment.results_dir)
REMOTE_HOST=$(cfg .remote.host)
REMOTE_DIR=$(cfg .remote.dir)
REMOTE_VENV=$(cfg .remote.venv)
SCRIPT=$(cfg .measurement.script)
NB_CONFS=$(cfg .measurement.nb_confs)
NB_ITERS=$(cfg .measurement.nb_iters)
NB_BENCHMARKS=$(cfg .measurement.nb_benchmarks)
OFFSET=$(cfg .measurement.offset)
ITER_OFFSET=$(cfg .measurement.iter_offset)
[[ $(cfg .measurement.timed_only) == true ]] && TIMED_ONLY=1 || TIMED_ONLY=0
MAX_CURRENT_LOWER=$(cfg .measurement.ina228.max_current_lower)
MAX_CURRENT_UPPER=$(cfg .measurement.ina228.max_current_upper)
NUM_CONF_SWITCH=$(cfg .measurement.ina228.num_conf_switch)
SHUNT_VAL=$(cfg .measurement.ina228.shunt_ohms)
DEADLINE_ITERATION=0 # unused by the measurement scripts

scp "$(dirname "$0")/$SCRIPT" "$REMOTE_HOST:$REMOTE_DIR/$SCRIPT"

if [[ "$2" != "nomon" ]]; then
	(ssh "$REMOTE_HOST" "kill \$(pgrep -f $SCRIPT)" || true)
	ssh "$REMOTE_HOST" "cd $REMOTE_DIR && source $REMOTE_VENV/bin/activate && nohup python -u $SCRIPT $NB_CONFS $NB_ITERS $OFFSET $ITER_OFFSET 0 $NB_BENCHMARKS $DEADLINE_ITERATION $MAX_CURRENT_LOWER $MAX_CURRENT_UPPER $NUM_CONF_SWITCH $SHUNT_VAL $TIMED_ONLY > measurements.log 2>&1 < /dev/null" < /dev/null &
	PID=$!
fi

if [[ "$2" != "nomon" ]]; then
	tail --pid=$PID -f /dev/null

	# retrieve results and create plot
	mkdir -p "$RESULTS_DIR/$EXPE_NAME"
	scp "$REMOTE_HOST:$REMOTE_DIR/results.csv" "$RESULTS_DIR/$EXPE_NAME/results.csv"
fi
