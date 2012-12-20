require 'buffered_io/read_buffer'

module BufferedIO
  # An +IOBuffer+ object wraps an +IO+ object and buffers read data for
  # efficient +IO+ manipulation.
  #
  # === Example
  #
  #   io_buffer = IOBuffer.new(io)
  #
  #   puts io_buffer.readline # => Read until a newline
  #   puts io_buffer.read(64) # => Read 64 bytes
  #
  class IOBuffer
    # Returns a new +IOBuffer+ object wrapping +io+.
    def initialize(io)
      @io = io
      @read_buffer = ReadBuffer.new(io)
    end

    # Read bytes from the underlying +IO+ object.
    #
    # === Parameters
    #
    # +length+ is the number of bytes to read.
    #
    # +dest+ is the buffer to append to.
    #
    # +ignore_eof+ indicates whether or not to ignore +EOFError+ exceptions.
    #
    # === Errors
    #
    # This method may raise:
    #
    # * +EOFError+
    #
    def read(length, dest = '', ignore_eof = false)
      read_bytes = 0
      begin
        while read_bytes + @read_buffer.size < length
          dest << (s = @read_buffer.consume(@read_buffer.size))
          read_bytes += s.size
          @read_buffer.fill
        end
        dest << (s = @read_buffer.consume(length - read_bytes))
        read_bytes += s.size
      rescue EOFError
        raise unless ignore_eof
      end
      dest
    end

    # Read all data from the underlying +IO+ object until an +EOFError+ is
    # raised by the +IO+ object.
    #
    # === Parameters
    #
    # +dest+ is the buffer to append to.
    #
    def read_all(dest = '')
      read_bytes = 0
      begin
        while true
          dest << (s = @read_buffer.consume(@read_buffer.size))
          read_bytes += s.size
          @read_buffer.fill
        end
      rescue EOFError
        ;
      end
      dest
    end

    # Read from the underlying +IO+ object until a specified terminator
    # is reached.
    #
    # === Parameters
    #
    # +terminator+ is the terminator to read until.
    #
    # +ignore_eof+ indicates whether or not to ignore +EOFError+ exceptions.
    #
    # === Errors
    #
    # This method may raise:
    #
    # * +EOFError+
    #
    def readuntil(terminator, ignore_eof = false)
      begin
        until idx = @read_buffer.index(terminator)
          @read_buffer.fill
        end
        return @read_buffer.consume(idx + terminator.size)
      rescue EOFError
        raise unless ignore_eof
        return @read_buffer.consume(@read_buffer.size)
      end
    end

    # Read a line from the underlying +IO+ object.
    #
    # === Parameters
    #
    # +chop+ indicates whether or not to strip the newline character from
    # the read data.
    #
    # === Errors
    #
    # This method may raise:
    #
    # * +EOFError+
    def readline(chop = true)
      s = readuntil("\n")
      return chop ? s.chop : s
    end

    # Writes bytes to the underlying +IO+ object.
    #
    # === Parameters
    #
    # +str+ is the data to write.
    def write(str)
      writing { write0 str }
    end

    # Appends a newline to a string and writes it to the underlying +IO+
    # object.
    #
    # === Parameters
    #
    # +str+ is the data to write.
    def writeline(str)
      writing { write0 str + "\r\n" }
    end

    private
    def writing
      @written_bytes = 0
      yield
      bytes = @written_bytes
      @written_bytes = nil
      bytes
    end

    def write0(str)
      length = @io.write(str)
      @written_bytes += length
      length
    end
  end
end

