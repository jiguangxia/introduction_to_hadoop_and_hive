# help
hadoop

# version
hadoop version

#
# hdfs
#
hadoop fs
hadoop fs -ls [dir_name]
hadoop fs -cat file_name
hadoop fs -mkdir dir_name
hadoop fs -put local_file hdfs_file
hadoop fs -get hdfs_file [local_file]
hadoop fs -rm file_name
hadoop fs -rmdir dir_name

#
# mapreduce
#

hadoop jar app.jar [class_name] input_path output_path

# input_path is a file
hadoop jar word_count.jar WordCount mr/lecture0/file1 mr/lecture0/result1

# input_path is a directory
hadoop jar word_count.jar WordCount mr/lecture0/input mr/lecture0/output

# if your .jar has specified a MAIN CLASS, you have to remove [class_name]
hadoop jar word_pair_count.jar mr/lecture0/input mr/lecture0/output
