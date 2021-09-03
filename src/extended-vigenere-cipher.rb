class ExtendedVigenereCipher
	def fit(text, key)
		# mengubah kunci sehingga |teks| = |kunci|, lalu mengembalikannya
		# apabila |teks| > |kunci|, karakter kunci ditambahkan secara periodik
		# apabila |teks| < |kunci|, beberapa karakter terakhir kunci dibuang
		if text.length > key.length
			m = key.length
			while text.length > key.length
				key += key[key.length - m]
			end
		end
		if text.length < key.length
			key = key[0, text.length]
		end
		key
	end

	def encrypt(plaintext, key)
		# mengembalikan hasil enkripsi plainteks dengan kunci tertentu
		if plaintext.empty?
			raise "Plainteks kosong!"
		end
		if key.empty?
			raise "Kunci kosong!"
		end
		# ubah k sehingga |p| = |k|
		key = fit(plaintext, key)
		# enkripsi p
		n = plaintext.length
		ciphertext = ""
		for i in 0..n-1
			ciphertext << ((plaintext[i].ord + key[i].ord) % 256).chr;
		end
		ciphertext
	end

	def decrypt(ciphertext, key)
		# mengembalikan hasil dekripsi cipherteks dengan kunci tertentu
		if ciphertext.empty?
			raise "Cipherteks kosong!"
		end
		if key.empty?
			raise "Kunci kosong!"
		end
		# ubah k sehingga |p| = |k|
		key = fit(ciphertext, key)
		# dekripsi c
		n = ciphertext.length
		plaintext = ""
		for i in 0..n-1
			plaintext << (((ciphertext[i].ord - key[i].ord) % 256 + 256) % 256).chr
		end
		plaintext
	end
end

class VariousClassicCiphers < Shoes
	def parseBinary(namafile)
		# mengembalikan string ascii hasil pembacaan sebuah file secara binary
		file = File.open(namafile, "rb")
		ascii = file.read.unpack("C*")
		ret = ""
		for i in ascii
			ret << i.chr
		end
		file.close
		return ret
	end

	def extendedVigenereCipher
		cipher = ExtendedVigenereCipher.new
		flow width: 1.0, margin: [0, 5, 0, 5] do
			tagline "Extended Vigenere Cipher", align: "center", underline: "single"
		end
		flow width: 1.0, margin: [0, 5, 0, 0] do
			para "kunci", align: 'center'
		end
		flow width: 1.0, margin: [0.3, 0, 0.3, 5] do
			@kunci = edit_line width: 1.0
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
					button "enkripsi", width: 1.0 do
						@cipherteks.text = cipher.encrypt(@plainteks.text, @kunci.text)
					rescue StandardError => e
						Shoes.alert e.message
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
					button "dekripsi", width: 1.0 do
						@plainteks.text = cipher.decrypt(@cipherteks.text, @kunci.text)
					rescue StandardError => e
						Shoes.alert e.message
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
		flow width: 1.0, margin: [0, 10, 0, 10] do
			stack width: 0.5, margin: [10, 0, 10, 0] do
				para "enkripsi file biner", align: "center", underline: "single"
				button "buka file plainteks", width: 1.0 do
					@namafile_plainteks = Shoes.ask_open_file
				end
				button "enkripsi", width: 1.0 do
					if @namafile_plainteks.empty?
						raise "File plainteks belum dipilih!"
					end
					@namafile_cipherteks = Shoes.ask_save_file
					File.open(@namafile_cipherteks, "w") do |file|
						file.write(cipher.encrypt(parseBinary(@namafile_plainteks), @kunci.text))
					end
					Shoes.alert "Cipherteks berhasil disimpan!"
				rescue StandardError => e
					Shoes.alert e.message
				end
			end
			stack width: 0.5, margin: [10, 0, 10, 0] do
				para "dekripsi file biner", align: "center", underline: "single"
				button "buka file cipherteks", width: 1.0 do
					@namafile_cipherteks = Shoes.ask_open_file
				end
				button "dekripsi", width: 1.0 do
					if @namafile_cipherteks.empty?
						raise "File cipherteks belum dipilih!"
					end
					@namafile_plainteks = Shoes.ask_save_file
					File.open(@namafile_plainteks, "w") do |file|
						file.write(cipher.decrypt(parseBinary(@namafile_cipherteks), @kunci.text))
					end
					Shoes.alert "Plainteks berhasil disimpan!"
				rescue StandardError => e
					Shoes.alert e.message
				end
			end
		end
		flow margin: [10, 0, 10, 0] do
			button "kembali ke menu" do
				visit "/"
			end
			button "info" do
				info = "1. Opsi tambah spasi (untuk mengelompokkan teks per 5 huruf) tidak diberikan"\
					" karena karakter spasi dapat ikut dienkripsi atau didekripsi."\
					"\n2. Known bug: beberapa karakter mungkin hilang dari edit box selama proses."\
					" Oleh sebab itu, hasil enkripsi/dekripsi file biner tidak ditampilkan di edit box agar aman."
				Shoes.alert info
			end
		end
	end
end

