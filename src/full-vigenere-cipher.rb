class FullVigenereCipher
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

	def generateRandomTable
		# mengembalikan tabel vigenere acak
		alphabet = ""
		for i in 0..25
			alphabet << (i+'A'.ord).chr
		end
		table = ""
		for i in 0..25
			table += alphabet.split("").shuffle.join
			table += "\n"
		end
		table
	end

	def encrypt(plaintext, key, table)
		# mengembalikan hasil enkripsi plainteks dengan kunci dan tabel tertentu
		# "bersihkan" plainteks, kunci, dan tabel
		plaintext = clean(plaintext)
		if plaintext.empty?
			raise "Plainteks tidak mengandung karakter alfabet!"
		end
		key = clean(key)
		if key.empty?
			raise "Kunci tidak mengandung karakter alfabet!"
		end
		table = clean(table)
		if table.length != 26 * 26
			raise "Tabel harus berisi 26 x 26 alfabet!"
		end
		# ubah kunci sehingga |plainteks| = |kunci|
		key = fit(plaintext, key)
		# enkripsi plainteks
		n = plaintext.length
		ciphertext = ""
		for i in 0..n-1
			ciphertext << table[(key[i].ord - 'A'.ord) * 26 + (plaintext[i].ord - 'A'.ord)]
		end
		ciphertext
	end

	def decrypt(ciphertext, key, table)
		# mengembalikan hasil dekripsi cipherteks dengan kunci dan tabel tertentu
		# "bersihkan" cipherteks, kunci, dan tabel
		ciphertext = clean(ciphertext)
		if ciphertext.empty?
			raise "Cipherteks tidak mengandung karakter alfabet!"
		end
		key = clean(key)
		if key.empty?
			raise "Kunci tidak mengandung karakter alfabet!"
		end
		table = clean(table)
		if table.length != 26 * 26
			raise "Tabel harus berisi 26 x 26 alfabet!"
		end
		# buat tabel balikan
		inv_table = []
		for i in 0..25
			row = ""
			for j in 0..25
				row << '*'
			end
			for j in 0..25
				row[table[i * 26 + j].ord - 'A'.ord] = (j + 'A'.ord).chr
			end
			inv_table << row
		end
		inv_table = inv_table.join
		# ubah kunci sehingga |cipherteks| = |kunci|
		key = fit(ciphertext, key)
		# dekripsi cipherteks
		n = ciphertext.length
		plaintext = ""
		for i in 0..n-1
			plaintext << inv_table[(key[i].ord - 'A'.ord) * 26 + (ciphertext[i].ord - 'A'.ord)]
		end
		plaintext
	end
end

class VariousClassicCiphers < Shoes
	def fullVigenereCipher
		cipher = FullVigenereCipher.new
		flow width: 1.0, margin: [0, 5, 0, 5] do
			tagline "Full Vigenere Cipher", align: "center", underline: "single"
		end
		stack width: 1.0, margin: [0.3, 5, 0.3, 5] do
			para "tabel", align: 'center'
			@tabel = edit_box(width: 1.0)
			File.open("./src/full-vigenere-cipher-table.txt") do |file|
				@tabel.text = file.read
			end
			button "bangkitkan tabel acak", width: 1.0 do
				@tabel.text = cipher.generateRandomTable
			end
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
		flow height: 0.4 do
			flow(width: 0.5, height: 1.0, margin: [10, 0, 10, 0]) {@plainteks = edit_box(width: 1.0, height: 1.0)}
			flow(width: 0.5, height: 1.0, margin: [10, 0, 10, 0]) {@cipherteks = edit_box(width: 1.0, height: 1.0)}
		end
		flow do
			flow width: 0.5, margin: [10, 0, 10, 0] do
				stack width: 1.0 do
					flow width: 1.0 do
						lebar = 1.0/3.0
						button "enkripsi", width: lebar do
							@cipherteks.text = cipher.encrypt(@plainteks.text, @kunci.text, @tabel.text)
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
							@plainteks.text = cipher.decrypt(@cipherteks.text, @kunci.text, @tabel.text)
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

