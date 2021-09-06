class EnigmaCipher
	def get_random_rotor()
		# mengembalikan rotor acak
		a = ""
		b = ""
		for i in 0..25
			a << ('A'.ord + i).chr
			b << ('A'.ord + i).chr
		end
		a = a.split("").shuffle.join
		b = b.split("").shuffle.join
		return [a, b]
	end

	def initialize
		# rotor yang dibangkitkan dengan metode di atas
		@rotors = [
			["HQBPYNWMRKCZUSLTDXAOEJFIVG", "PKOGBQUFANRYMHJXTWISCVZLDE"],
			["AXBDNYRJOFGZSWMTLUQVHCPIKE", "JTZBPNYUSWODQAMECLKGHIVFRX"],
			["AIGLTPHVMUFODBZCEXKWJQYNSR", "SBUJDPMWRZVFKQYHNLIGOXEATC"]
		]
	end

	def clean(s)
		# mengembalikan string s yang telah "dibersihkan"
		# menghapus karakter non-alfabet
		s.gsub!(/[^a-zA-Z]/, "")
		# mengubah karakter lowercase menjadi uppercase
		for i in 'a'.ord..'z'.ord
			s.gsub!(i.chr, (i - 'a'.ord + 'A'.ord).chr)
		end
		s
	end

	def crypt(text, keys)
		# mengembalikan hasil enkripsi/dekripsi plainteks/cipherteks dengan kunci tertentu
		# prekondisi: array keys berukuran 3
		# "bersihkan" plainteks dan kunci
		text = clean(text)
		if text.empty?
			raise "Plainteks tidak mengandung karakter alfabet!"
		end
		for i in 0..2
			keys[i] = clean(keys[i])
			if keys[i].length != 1
				raise "Terdapat kunci yang tidak tepat! Setiap kunci harus merupakan satu karakter alfabet (A-Z)." 
			end
		end
		# sesuaikan rotor
		for i in 0..2
			while @rotors[i][0][0] != keys[i]
				@rotors[i][0] = @rotors[i][0][1, 25] + @rotors[i][0][0]
				@rotors[i][1] = @rotors[i][1][1, 25] + @rotors[i][1][0]
			end
		end
		# enkripsi plainteks
		n = text.length
		result = ""
		for i in 0..n-1
			# puts keys.join
			pos = -1
			for j in 0..25
				if @rotors[0][0][j] == text[i]
					pos = j
				end
			end
			for j in 0..2
				next_pos = -1
				for k in 0..25
					if @rotors[j][1][k] == @rotors[j][0][pos]
						next_pos = k
					end
				end
				pos = next_pos
			end
			# reflektor
			next_pos = -1
			for j in 0..25
				if (@rotors[2][1][j].ord + @rotors[2][1][pos].ord) == ('A'.ord + 'Z'.ord)
					next_pos = j
				end
			end
			pos = next_pos
			for j in 2.downto(0)
				next_pos = -1
				for k in 0..25
					if @rotors[j][0][k] == @rotors[j][1][pos]
						next_pos = k
					end
				end
				pos = next_pos
			end
			# tambahkan karakter ke result
			result << @rotors[0][0][pos]
			# putar rotor
			m = 1
			for j in 0..2
				if (i+1) % m == 0
					@rotors[j][0] = @rotors[j][0][1, 25] + @rotors[j][0][0]
					@rotors[j][1] = @rotors[j][1][1, 25] + @rotors[j][1][0]
				end
				m *= 26
			end
		end
		result
	end
end

class VariousClassicCiphers < Shoes
	def enigmaCipher
		cipher = EnigmaCipher.new
		flow width: 1.0, margin: [0, 5, 0, 5] do
			tagline "Enigma Cipher", align: "center", underline: "single"
		end
		flow width: 1.0, margin: [0, 5, 0, 0] do
			para "kunci", align: 'center'
		end
		flow width: 1.0, margin: [0.3, 0, 0.3, 5] do
			para "rotor 1: ", width: 0.25
			@key1 = edit_line width: 0.75
			para "rotor 2: ", width: 0.25
			@key2 = edit_line width: 0.75
			para "rotor 3: ", width: 0.25
			@key3 = edit_line width: 0.75
		end
		flow do
			flow(width: 0.5, margin: [10, 0, 10, 0]) {para "plainteks", align: 'center'}
			flow(width: 0.5, margin: [10, 0, 10, 0]) {para "cipherteks", align: 'center'}
		end
		flow height: 0.5 do
			flow(width: 0.5, height: 1.0, margin: [10, 0, 10, 0]) {@plainteks = edit_box(width: 1.0, height: 1.0)}
			flow(width: 0.5, height: 1.0, margin: [10, 0, 10, 0]) {@cipherteks = edit_box(width: 1.0, height: 1.0)}
		end
		flow do
			flow width: 0.5, margin: [10, 0, 10, 0] do
				stack width: 1.0 do
					flow width: 1.0 do
						lebar = 1.0/3.0
						button "enkripsi", width: lebar do
							@cipherteks.text = cipher.crypt(@plainteks.text, [@key1.text, @key2.text, @key3.text])
						rescue StandardError => e
							Shoes.alert e.message
						end
						button "hapus spasi", width: lebar do
							@plainteks.text = cipher.clean(@plainteks.text)
						end
						button "tambah spasi", width: lebar do
							@plainteks.text = cipher.clean(@plainteks.text)
							tmp = ""
							for i in (0..@plainteks.text.length-1).step(5)
								tmp += @plainteks.text[i, 5]
								tmp += " "
							end
							@plainteks.text = tmp
						end
					end
					flow width: 1.0 do
						button "buka file plainteks", width: 0.5 do
							@namafile_plainteks = Shoes.ask_open_file
							File.open(@namafile_plainteks) do |file|
								@plainteks.text = file.read
							end
						end
						button "simpan file plainteks", width: 0.5 do
							@namafile_plainteks = Shoes.ask_save_file
							File.open(@namafile_plainteks, "w") do |file|
								file.write(@plainteks.text)
							end
							Shoes.alert "Plainteks berhasil disimpan!"
						end
					end
				end
			end
			flow width: 0.5, margin: [10, 0, 10, 0] do
				stack width: 1.0 do
					flow width: 1.0 do
						lebar = 1.0/3.0
						button "dekripsi", width: lebar do
							@plainteks.text = cipher.crypt(@cipherteks.text, [@key1.text, @key2.text, @key3.text])
						rescue StandardError => e
							Shoes.alert e.message
						end
						button "hapus spasi", width: lebar do
							@cipherteks.text = cipher.clean(@cipherteks.text)
						end
						button "tambah spasi", width: lebar do
							@cipherteks.text = cipher.clean(@cipherteks.text)
							tmp = ""
							for i in (0..@cipherteks.text.length-1).step(5)
								tmp += @cipherteks.text[i, 5]
								tmp += " "
							end
							@cipherteks.text = tmp
						end
					end
					flow width: 1.0 do
						button "buka file cipherteks", width: 0.5 do
							@namafile_cipherteks = Shoes.ask_open_file
							File.open(@namafile_cipherteks) do |file|
								@cipherteks.text = file.read
							end
						end
						button "simpan file cipherteks", width: 0.5 do
							@namafile_cipherteks = Shoes.ask_save_file
							File.open(@namafile_cipherteks, "w") do |file|
								file.write(@cipherteks.text)
							end
							Shoes.alert "Cipherteks berhasil disimpan!"
						end
					end
				end
			end
		end
		stack margin: [10, 10, 10, 10] do
			button "kembali ke menu" do
				visit "/"
			end
		end
	end
end