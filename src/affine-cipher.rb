class AffineCipher
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

	def is_positive_integer?(s)
		# mengembalikan true apabila string s menyatakan bilangan bulat positif
		return /\A\d+\z/.match(s)
	end

	def gcd(a, b)
		# mengembalikan bilangan terbesar yang membagi habis a dan b
		while b > 0
			a, b = b, a%b
		end
		a
	end

	def encrypt(plaintext, m, b)
		# mengembalikan hasil enkripsi plainteks dengan kunci m dan b
		# "bersihkan" plainteks
		plaintext = clean(plaintext)
		if plaintext.empty?
			raise "Plainteks tidak mengandung karakter alfabet!"
		end
		# cek m dan b bilangan bulat atau bukan
		if !is_positive_integer?(m)
			raise "m bukan bilangan bulat positif!"
		end
		if !is_positive_integer?(b)
			raise "b bukan bilangan bulat positif!"
		end
		m = m.to_i
		b = b.to_i
		# cek m relatif prima dengan 26 atau tidak
		if gcd(m, 26) != 1
			raise "Kunci tidak relatif prima dengan 26!"
		end
		# enkripsi plainteks
		n = plaintext.length
		ciphertext = ""
		for i in 0..n-1
			ciphertext << (((plaintext[i].ord - 'A'.ord) * m + b) % 26 + 'A'.ord).chr
		end
		ciphertext
	end

	def decrypt(ciphertext, m, b)
		# mengembalikan hasil dekripsi cipherteks dengan kunci m dan b
		# "bersihkan" cipherteks
		ciphertext = clean(ciphertext)
		if ciphertext.empty?
			raise "Cipherteks tidak mengandung karakter alfabet!"
		end
		# cek m dan b bilangan bulat atau bukan
		if !is_positive_integer?(m)
			raise "m bukan bilangan bulat positif!"
		end
		if !is_positive_integer?(b)
			raise "b bukan bilangan bulat positif!"
		end
		m = m.to_i
		b = b.to_i
		# cek m relatif prima dengan 26 atau tidak
		if gcd(m, 26) != 1
			raise "Kunci tidak relatif prima dengan 26!"
		end
		# cari balikan m dengan bruteforce
		inv_m = 0
		for i in 1..25
			if m * i % 26 == 1
				inv_m = i
			end
		end
		# dekripsi cipherteks
		n = ciphertext.length
		plaintext = ""
		for i in 0..n-1
			plaintext << ((((ciphertext[i].ord - 'A'.ord) - b) * inv_m % 26 + 26) % 26 + 'A'.ord).chr
		end
		plaintext
	end
end

class VariousClassicCiphers < Shoes
	def affineCipher
		cipher = AffineCipher.new
		flow width: 1.0, margin: [0, 5, 0, 5] do
			tagline "Affine Cipher", align: "center", underline: "single"
		end
		flow width: 1.0, margin: [0, 5, 0, 0] do
			para "kunci", align: 'center'
		end
		flow width: 1.0, margin: [0.3, 0, 0.3, 5] do
			para "m: ", width: 0.1
			@m = edit_line width: 0.9
			para "b: ", width: 0.1
			@b = edit_line width: 0.9
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
							@cipherteks.text = cipher.encrypt(@plainteks.text, @m.text, @b.text)
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
							@plainteks.text = cipher.decrypt(@cipherteks.text, @m.text, @b.text)
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
			end# berisi tombol-tombol GUI, tidak diperlihatkan karena panjang
		end
		stack margin: [10, 10, 10, 10] do
			button "kembali ke menu" do
				visit "/"
			end
		end
	end
end

