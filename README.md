# AMD Tuning application

The app runs AMD using specified parameters against the Asterisk server it is connected to.

The samples need to be in a place that is reachable by Asterisk, in the path defined by ```config.amd_tuner.samples_dir```.

## CLI interface

The ```runner``` script in the script/ folder provides an interface that allows for parallel execution, dumping of results to a CSV file and more fine-grained control.

```
$ bundle exec script/runner --help
Usage: runner [file_id|ALL] [options]
    -v, --[no-]verbose               Run verbosely
    -s, --[no-]summary               Print summary
    -c, --[no-]csv                   Write results to CSV
        --num_threads N              num_threads - Default: 3
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

Results are written to logs/amd_tuning.csv.

3 is the optimal number of threads for low-powered VMs, always pay attention to the increasing average detection time if looking to raise the number.

## Web interface

Reachable at http://AHN_IP:8080 (configured by the usual Virginia configuration), it is slow for running all the files but can provide a nice feedback.