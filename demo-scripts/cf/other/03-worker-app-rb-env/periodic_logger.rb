$stdout.sync = true

data = ENV.fetch("OUTPUT_TEXT", "none")

(1..Float::INFINITY).each do
  $stdout.puts "Doing some work (env = #{data})..."
  sleep 5
end