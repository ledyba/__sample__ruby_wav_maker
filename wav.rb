class Composer
	def initialize(sample_rate,bitswidth,channels,data)
		@sample_rate = sample_rate
		@bitswidth = bitswidth
		raise 'bitswidth must be 8 or 16 bits.' unless @bitswidth == 8 || @bitswidth == 16
		@channel = channels
		raise 'channels must be 1 or 2.' unless channels > 0 && channels <= 2
		@data = data
		@datasize = @data.size * (@bitswidth / 8)
	end
	def out(io)
		close_needed = io.kind_of?(String)
		if close_needed
			io = open(io,"wb")
		end
		io.print 'RIFF'
		#データサイズ
		io.print [@datasize + 38].pack('V')
		io.print 'WAVE'
		#フォーマットチャンク　計26バイト
		io.print 'fmt '
		io.print [18].pack('V')
		io.print [1].pack('v')
		io.print [@channel].pack('v')
		io.print [@sample_rate].pack('V')
		data_rate = @channel * @sample_rate * @bitswidth / 8
		io.print [data_rate].pack('V')
		io.print [@channel * @bitswidth / 8].pack('v')
		io.print [@bitswidth].pack('v')
		io.print [0].pack('v')
		#データチャンク @datasize + 8バイト
		io.print 'data'
		io.print [@datasize].pack('V')
		for i in 0..@data.size-1
			io.print [@data[i]].pack('v')
		end
		if close_needed
			io.close
		end
		return true
	end
end

dat = Array.new(44100)

freq = 1000
for i in 0..dat.size-1
	dat[i] = (Math.sin(2 * Math::PI * i * 44100 / freq) * 32767).to_i
end

comp = Composer.new(44100,16,1,dat)
comp.out 'test.wav'

