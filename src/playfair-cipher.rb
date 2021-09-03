class PlayfairCipher
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

	def checkKey(key)
		# mengembalikan true apabila key merupakan kunci playfair cipher yang valid
		if key.length != 25
			return false
		end
		key = key.chars.sort.join
		for i in 0..23
			if key[i] == key[i+1] || key[i] == 'J'
				return false
			end
		end
		return true
	end

	def preprocessPlaintext(plaintext)
		# mengembalikan plainteks yang sudah diatur
		plaintext = clean(plaintext)
		# mengganti huruf j dengan i
		plaintext.gsub!(/[J]/, "I")
		# menyisipkan X di antara huruf sama (atau Y di antara dua X)
		tmp = ""
		for i in 0..plaintext.length-1
			if i > 0
				if plaintext[i] == plaintext[i-1]
					if plaintext[i] == 'X'
						tmp << 'Y'
					else
						tmp << 'X'
					end
				end
			end
			tmp << plaintext[i]
		end
		plaintext = tmp
		# apabila panjang plaintext ganjil, tambahkan X di akhir
		if plaintext.length%2 == 1
			plaintext << 'X'
		end
		plaintext
	end

	def encrypt(plaintext, key)
		# mengembalikan hasil enkripsi plaintext dengan kunci tertentu
		# preprocess plainteks dan "bersihkan" kunci
		plaintext = preprocessPlaintext(plaintext)
		if plaintext.empty?
			raise "Plainteks tidak mengandung karakter alfabet!"
		end
		key = clean(key)
		if !checkKey(key)
			raise "Kunci tidak valid!"\
			" Kunci valid apabila mengandung mengandung semua alfabet kecuali J tepat satu kali"\
			" dan tidak mengandung J."
		end
		# simpan baris dan kolom huruf-huruf kunci
		row = Array.new(26)
		col = Array.new(26)
		for i in 0..key.length-1
			row[key[i].ord-'A'.ord] = i/5
			col[key[i].ord-'A'.ord] = i%5
		end
		# enkripsi p
		n = plaintext.length
		ciphertext = ""
		for i in (0..n-2).step(2)
			row1 = row[plaintext[i].ord-'A'.ord]
			row2 = row[plaintext[i+1].ord-'A'.ord]
			col1 = col[plaintext[i].ord-'A'.ord]
			col2 = col[plaintext[i+1].ord-'A'.ord]
			if row1 == row2
				col1 = (col1 + 1) % 5
				col2 = (col2 + 1) % 5
			elsif col1 == col2
				row1 = (row1 + 1) % 5
				row2 = (row2 + 1) % 5
			else
				col1, col2 = col2, col1
			end
			ciphertext << key[row1*5 + col1]
			ciphertext << key[row2*5 + col2]
		end
		ciphertext
	end

	def decrypt(ciphertext, key)
		# mengembalikan hasil dekripsi cipherteks dengan kunci tertentu
		# "bersihkan" cipherteks dan kunci
		ciphertext = clean(ciphertext)
		if ciphertext.empty?
			raise "Cipherteks tidak mengandung karakter alfabet!"
		end
		key = clean(key)
		if !checkKey(key)
			raise "Kunci tidak valid!"\
			" Kunci valid apabila mengandung mengandung semua alfabet kecuali J tepat satu kali"\
			" dan tidak mengandung J."
		end
		# simpan baris dan kolom huruf-huruf kunci
		row = Array.new(26)
		col = Array.new(26)
		for i in 0..key.length-1
			row[key[i].ord-'A'.ord] = i/5
			col[key[i].ord-'A'.ord] = i%5
		end
		# dekripsi c
		n = ciphertext.length
		plaintext = ""
		for i in (0..n-2).step(2)
			row1 = row[ciphertext[i].ord-'A'.ord]
			row2 = row[ciphertext[i+1].ord-'A'.ord]
			col1 = col[ciphertext[i].ord-'A'.ord]
			col2 = col[ciphertext[i+1].ord-'A'.ord]
			if row1 == row2
				col1 = (col1 + 4) % 5
				col2 = (col2 + 4) % 5
			elsif col1 == col2
				row1 = (row1 + 4) % 5
				row2 = (row2 + 4) % 5
			else
				col1, col2 = col2, col1
			end
			plaintext << key[row1*5 + col1]
			plaintext << key[row2*5 + col2]
		end
		plaintext
	end
end

class VariousClassicCiphers < Shoes
	def playfairCipher
		cipher = PlayfairCipher.new
		flow width: 1.0, margin: [0, 5, 0, 5] do
			tagline "Playfair Cipher", align: "center", underline: "single"
		end
		flow width: 1.0, margin: [0, 5, 0, 0] do
			para "kunci", align: 'center'
		end
		flow width: 1.0, margin: [0.3, 0, 0.3, 5] do
			@kunci = edit_box width: 1.0
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
							@cipherteks.text = cipher.encrypt(@plainteks.text, @kunci.text)
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
							@plainteks.text = cipher.decrypt(@cipherteks.text, @kunci.text)
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