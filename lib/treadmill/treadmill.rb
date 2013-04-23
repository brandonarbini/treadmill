class Treadmill

  INIT_SEQUENCE = [
    "\x02\x00\x00\x00\x00", # Unknown (0x11, 0x01)
    "\xC2\x00\x00\x00\x00", # Firmware (2 bytes, major/minor)
    "\xE9\xFF\x00\x00\x00", # Zeroes
    "\xE4\x00\xF4\x00\x00"  # Zeroes
  ]

  INFO_QUERIES = {
    :unknown =>  "\xA1\x81\x00\x00\x00",
    :steps =>    "\xA1\x88\x00\x00\x00",
    :calories => "\xA1\x87\x00\x00\x00",
    :distance => "\xA1\x85\x00\x00\x00",
    :time =>     "\xA1\x89\x00\x00\x00",
    :speed =>    "\xA1\x82\x00\x00\x00"
  }

  def initialize(tty_location="/dev/tty.IHP-Serialport")
    @tty = File.open(tty_location, 'w+')
    @tty.sync = true
    init_responses = INIT_SEQUENCE.map { |c| send_command(c) }
    @firmware = to_decimal(init_responses[1])
    if @firmware <= 0.0
      puts "Couldn't find treadmill. Check the bluetooth connection."
      exit 1
    end
  rescue Errno::EBUSY
    puts "The treadmill interface is busy."
    exit 1
  end

  def start
    send_command("\xE1\x00\x00\x00\x00")
  end

  def stop
    send_command("\xE0\x00\x00\x00\x00")
  end

  def steps
    to_number(send_command(INFO_QUERIES[:steps]))
  end

  def distance
    to_decimal(send_command(INFO_QUERIES[:distance]))
  end

  def time
    to_time(send_command(INFO_QUERIES[:time]))
  end

  def seconds
    to_seconds(send_command(INFO_QUERIES[:time]))
  end

  def calories
    to_number(send_command(INFO_QUERIES[:calories]))
  end

  def speed
    to_decimal(send_command(INFO_QUERIES[:speed]))
  end

  def speed=(new_speed)
    new_speed = (new_speed * 100.0).round
    units = new_speed / 100
    hundredths = new_speed % 100
    send_command([0xd0, units, hundredths,0, 0].pack('C*'))
  end

  def stats
    info            = {}
    info[:steps]    = steps
    info[:calories] = calories
    info[:distance] = distance
    info[:time]     = time
    info[:speed]    = speed
    info[:seconds]  = seconds
    info
  end


private

  def send_command(c)
    @tty.syswrite(c)
    tries = 0
    response = nil
    begin
      response = @tty.sysread(6)
    rescue Interrupt, Errno::EINTR
      sleep 0.2
      tries += 1
      # STDOUT.puts "got exception -- tries = #{tries}"
      retry if tries < 3
      raise
    end
    response
  end

  def to_decimal(response_string)
    response_string[2,1].unpack("C").first + (response_string[3,1].unpack("C").first / 100.0)
  end

  def to_time(response_string)
    h,m,s = response_string[2,3].unpack("CCC")
    "%02d:%02d:%02d" % [h,m,s]
  end

  def to_seconds(response_string)
    h,m,s = response_string[2,3].unpack("CCC")
    (h * 3600) + (m * 60) + s
  end

  def to_number(response_string)
    response_string[2,2].unpack('n').first
  end

end
