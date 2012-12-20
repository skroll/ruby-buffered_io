module BufferedIO
  # Maintains a read buffer for an IO object.
  class ReadBuffer # :nodoc:
    # :nodoc:
    DEFAULT_BUFFER_SIZE = 1024 * 16

    def initialize(io)
      @io = io
      @buffer = ''
      @read_timeout = 60
      @buffer_size = DEFAULT_BUFFER_SIZE
    end

    attr_reader :io
    attr_accessor :read_timeout

    # Attempt to fill the IOBuffer
    def fill
      begin
        @buffer << @io.read_nonblock(@buffer_size)
      rescue ::IO::WaitReadable
        IO.select([@io], nil, nil, @read_timeout) ? retry : (raise ::Timeout::Error)
      rescue ::IO::WaitWritable
        IO.select(nil, [@io], nil, @read_timeout) ? retry : (raise ::Timeout::Error)
      end
    end

    # Consume bytes from the IOBuffer
    def consume(len)
      return @buffer.slice!(0, len)
    end

    # Number of bytes in the buffer
    def size
      @buffer.size
    end

    def index(i)
      @buffer.index(i)
    end
  end
end

