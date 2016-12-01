import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.net.URI;
import java.util.HashSet;
import java.util.Arrays;
import java.util.ArrayList;

public class WordPairCount {

    public static class TokenizerMapper
            extends Mapper<Object, Text, Text, IntWritable>{

        private final static IntWritable one = new IntWritable(1);
        private Text word = new Text();
        private ArrayList<String[]> wordPair = new ArrayList<String[]>();

        protected void setup(Context context) throws IOException, InterruptedException{
            Configuration conf = context.getConfiguration();
            URI[] localFiles = Job.getInstance(conf).getCacheFiles();
            Path localPath = new Path(localFiles[0].getPath());
            BufferedReader readBuffer1 = new BufferedReader(new FileReader(localPath.getName()));
            String line;
            while ((line=readBuffer1.readLine())!=null){
                String[] wd = line.split(" ");
                wordPair.add(wd);
            }
            readBuffer1.close();
        }

        public void map(Object key, Text value, Context context
        ) throws IOException, InterruptedException {
            String[] lines = value.toString().split("\n");
            for (String line : lines) {
                String[] arr = line.split(" ");
                HashSet<String> set = new HashSet<String>(Arrays.asList(arr));
                for (int i = 0; i < wordPair.size(); i++) {
                    String[] wp = wordPair.get(i);
                    if (set.contains(wp[0]) && set.contains(wp[1])) {
                        word.set(wp[0]+'-'+wp[1]);
                        context.write(word, one);
                    }
                }
            }
        }
    }

    public static class IntSumReducer
            extends Reducer<Text,IntWritable,Text,IntWritable> {
        private IntWritable result = new IntWritable();

        public void reduce(Text key, Iterable<IntWritable> values,
                           Context context
        ) throws IOException, InterruptedException {
            int sum = 0;
            for (IntWritable val : values) {
                sum += val.get();
            }
            result.set(sum);
            context.write(key, result);
        }
    }

    public static void main(String[] args) throws Exception {
        Configuration conf = new Configuration();
        Job job = Job.getInstance(conf, "word count");
        job.addCacheFile(new URI("/user/mart_cis/mr/lecture0/file2"));
        job.setJarByClass(WordPairCount.class);
        job.setMapperClass(TokenizerMapper.class);
        job.setCombinerClass(IntSumReducer.class);
        job.setReducerClass(IntSumReducer.class);
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(IntWritable.class);
        FileInputFormat.addInputPath(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));
        System.exit(job.waitForCompletion(true) ? 0 : 1);
    }
}