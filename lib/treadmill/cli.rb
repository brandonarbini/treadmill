class Treadmill
  class CLI < Thor

    map "-v" => "version", "--version" => "version"
    map "-h" => "help", "--help" => "help"

    desc "version", "Show treadmill version.", :hide => true
    def version
      puts "Treadmill #{Treadmill::VERSION}"
    end

    desc "help", "Show treadmill help.", :hide => true
    def help
      version
      puts
      puts "Options:"
      puts "  -h, --help      # Prints help"
      puts "  -v, --version   # Prints treadmill version"
      puts
      super
    end


    class_option :loop, :type => :boolean, :desc => "Continuously print the report", :aliases => :l

    desc "stats", "Shows the current treadmill stats"
    def stats
      keys = [:time, :seconds, :steps, :calories, :distance, :speed]
      output = proc {
        info = treadmill.stats
        keys.each do |k|
          puts "#{(k.to_s.upcase+":").ljust(10)} #{info[k]}"
        end
      }
      output.call
      if options[:loop]
        loop do
          sleep 2
          puts "--"
          output.call
        end
      end
    rescue Interrupt
    end

    desc "steps", "Show the current step count"
    def steps
      puts treadmill.steps
      if options[:loop]
        loop do
          sleep 2
          puts "--"
          puts treadmill.steps
        end
      end
    rescue Interrupt
    end

    desc "distance", "Show the current distance"
    def distance
      puts treadmill.distance
      if options[:loop]
        loop do
          sleep 2
          puts "--"
          puts treadmill.distance
        end
      end
    rescue Interrupt
    end

    desc "calories", "Show the current calories"
    def calories
      puts treadmill.calories
      if options[:loop]
        loop do
          sleep 2
          puts "--"
          puts treadmill.calories
        end
      end
    rescue Interrupt
    end

    desc "time", "Show the current time"
    def time
      puts treadmill.time
      if options[:loop]
        loop do
          sleep 2
          puts "--"
          puts treadmill.time
        end
      end
    rescue Interrupt
    end

    desc "seconds", "Show the current seconds"
    def seconds
      puts treadmill.seconds
      if options[:loop]
        loop do
          sleep 2
          puts "--"
          puts treadmill.seconds
        end
      end
    rescue Interrupt
    end

    desc "speed [SPEED]", "Show or set the current speed"
    def speed(new_speed=nil)
      if new_speed
        new_speed_f = new_speed.to_f
        if new_speed_f <= 0 || new_speed_f > 4
          puts "#{new_speed} is not a valid speed setting"
          exit 1
        else
          treadmill.speed = new_speed_f
          puts "Treadmill speed is now #{new_speed}"
        end
      else
        puts treadmill.speed
        if options[:loop]
          loop do
            sleep 2
            puts "--"
            puts treadmill.speed
          end
        end
      end
    rescue Interrupt
    end

    desc "start [SPEED]", "Start the treadmill and optionally set speed"
    def start(new_speed=nil)
      treadmill.start
      puts "Treadmill is started"
      new_speed ||= Config["speed"]
      if new_speed
        puts "Setting speed to #{new_speed} in 5 seconds..."
        sleep 5
        speed(new_speed)
      end
    end

    desc "pause", "Pause the treadmill"
    def pause
      treadmill.stop
      puts "Treadmill is paused"
    end

    desc "defaults [KEY] [VALUE]", "Display or set defaults"
    def defaults(key=nil, value=nil)
      if key && value
        Treadmill::Config[key] = value
        puts "Setting default for '#{key}' to '#{value}'"
      elsif key
        puts "Default for '#{key}' is '#{Treadmill::Config[key]}'"
      else
        puts "All defaults:"
        pp Treadmill::Config.load!
      end
    end


  protected

    def treadmill
      @treadmill ||= Treadmill.new
    end

  end
end
