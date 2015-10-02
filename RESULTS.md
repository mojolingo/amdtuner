# AMD tuning

The goal for this AMD tuning work is reach an accuracy between 80% and 85% while lowering the execution times as much as possible and minimizing false positives.

False positives are defined as "an human is answering but we detect an answering machine" which results in a customer getting the recorded message, a worse case than an agent hitting an answering machine by mistake.

Studies indicate that a personalized message left on an answering machine by a human is even more effective than a recorded one, so false negatives do not concern us as long as the accuracy is above 80%.

## Methodology

An application has been constructed to evaluate each sample in a repeatable and parallelized manner.

Over 150 samples have been manually selected from the PHRG corpus to present a varied enough domain of work.

All parameters have been tested in isolation first, to establish baseline values and boundaries.
Another series of normalized runs with the parameters currently in use helped finalize the target numbers.

After this set of preliminary runs, another variable has been introduced. Asterisk documentation indicates that playing about 50 milliseconds of silence before activating AMD improves results, and so we set out to measure the effect that has on accuracy and recognition times. The addition proved beneficial as will be discussed further on in the document.

Each sample run has been executed multiple times and averaged to obtain time-independent results.

## Application structure

The execution environment is an Adhearsion 2 application, that exposes a web GUI through HTTP and a CLI interface through DRb.

An Asterisk server provides the AMD and playback functionality, essentially dialing into itself and executing a dialplan.

That is not a cause for concern regarding performance and results, as all tests are run on the same setup, thus giving us comparability and repeatability.

The application automatically counts, detects and runs all samples placed in the ```samples/``` directory, provided they are labeled with "human" or "machine" in the file name.

Use of the CLI interface is recommended as it is quicker, stabler and provides more options.

## Web interface

Reachable at http://APPLICATION_IP:8080. Slow for full tests but has the ability to run single files interactively.

### CLI interface help screen

```
Usage: runner [file_id|ALL] [@options]
    -v, --[no-]verbose               Run verbosely
    -s, --[no-]summary               Print summary
    -c, --[no-]csv                   Write results to CSV
    -f, --file [FILENAME]            Filename to write results to (defaults to amd_tuning_results.csv)
    -w, --[no-]write                 Write logs to file defined by -l
    -l, --log [FILENAME]             Filename to write logs to (defaults to amd_logs.csv))
    -p, --[no-]presilence            Play 50ms silence before activating AMD
        --num_threads N              num_threads - Default: 3
        --times_to_run N             times_to_run - Default: 1
        --presilence N               presilence - Default: true
        --initial_silence N          initial_silence - Default: 2500
        --greeting N                 greeting - Default: 1500
        --after_greeting_silence N   after_greeting_silence - Default: 800
        --total_analysis_time N      total_analysis_time - Default: 5000
        --min_word_length N          min_word_length - Default: 100
        --between_words_silence N    between_words_silence - Default: 50
        --maximum_number_of_words N  maximum_number_of_words - Default: 3
        --silence_threshold N        silence_threshold - Default: 256
    -h, --help                       Display this screen
```

An example can be run as follows:

```
cd APPLICATION_PATH;
script/runner ALL --no-csv --no-summary --initial_silence 1500
```

All logs are written in the ```log/```directory of the Adhearsion application.

3 is the optimal number of threads for low-powered VMs, always pay attention to the increasing average detection time if looking to raise the number, as each thread will compete for resources.

### Metrics collected

Each .csv file has columns labeled for the pre-silence presence, plus the configuration parameters used.

Those are followed by:
* total: number of samples evaluated
* correct: number of correcly recognized samples
* correct_percent: percent of correct results
* false_positives: human samples recognized as machines
* false_negatives: machine samples recognized as machines
* total_amd_time: total time spent doing AMD
* average_time: average time for each recognition
* execution_time: total execution time for the script, used to time


## Configuration parameters

### initial_silence

Controls maximum silence duration before the greeting. If it is exceeded then the result is MACHINE.

A high value of 5000 seems to reduce false positives, and if mitigated by a low total\_analysis\_time does not modify AMD time.

### greeting

Maximum length of a greeting. If it is exceeded then the far end is a MACHINE.

Any value seems to not impact results in a significant way, but lowering the time raises false positives which is unwanted in absence of other benefits.

### after\_greeting\_silence

Silence after detecting a greeting. If the greeting is longer then  the far end is a HUMAN.

Lowering this to 400 from the default value of 800 does not impact accuracy other than shifting some false positives to negative, but improves performance by 15%.

### total_analysis_time

Maximum time allowed for the algorithm to decide on a HUMAN or MACHINE. This is not the total maximum running time, which can not be controlled as it includes call setup and teardown which are network and machine dependent.

Running at 2500 instead of 5000 has a beneficial effect as there is an average gain of .4s.

On top of that, false positives are actually reduced, at a cost of about 4% efficiency which is mostly eaten up by false negatives.

### min\_word\_length

Minimum duration of voice to considered as a word.

Lowering this slightly raises accuracy at a loss of performance. Currently not considered for the first testing batch but might be used to counterbalance values that reduce both time and accuracy.

### between\_words\_silence

Minimum duration of silence after a word to consider the following audio as a new word.

A parameter that is more involved in accuracy than performance, this does not affect the numbers in any meaningful way unless set to substantially high or low values to the point of just breaking the algorithm.

### maximum\_number\_of_words

Maximum number of words in the greeting. If exceeded then the far side is a MACHINE.

Reducing this to 1 from the default 3 completely breaks AMD. Raising the value seems to not affect results too much, possibly because of the chosen samples.

### silence_threshold

The noise level considered as silence during AMD. It is a function of quality of service and the phone lines involved, so it is safe to state that the default value of 256 will be good.

Some fine tuning here might be considered after a first phase of testing using more influential parameters.

## Conclusions

The created application presents an ideal environment for the first phase of tuning and for ongoing work, and could be adapted to run automatically on a staging box.

Our recommendation is to start a sample test period using after\_greeting\_silence at 400 and total\_analysis\_time at 2500, closely monitoring connection time and looking for the lowest possbile AMD time.

After this first step, the general plan will be to start bringing back in a few of the parameters that impact accuracy positively, to reach optimal balance.