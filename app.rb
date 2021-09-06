require_relative "./src/standard-vigenere-cipher"
require_relative "./src/autokey-vigenere-cipher"
require_relative "./src/full-vigenere-cipher"
require_relative "./src/extended-vigenere-cipher"
require_relative "./src/playfair-cipher"
require_relative "./src/affine-cipher"
require_relative "./src/enigma-cipher"

class VariousClassicCiphers < Shoes

	url "/", :index
	url "/standard-vigenere-cipher", :standardVigenereCipher
	url "/full-vigenere-cipher", :fullVigenereCipher
	url "/autokey-vigenere-cipher", :autokeyVigenereCipher
	url "/extended-vigenere-cipher", :extendedVigenereCipher
	url "/playfair-cipher", :playfairCipher
	url "/affine-cipher", :affineCipher
	url "/enigma-cipher", :enigmaCipher

	def index
		stack margin: [0, 5, 0, 5] do
			title "Various Classic Ciphers", align: "center", underline: "single"
			tagline "kumpulan cipher-cipher klasik", align: "center"
		end
		stack margin: [0.3, 5, 0.3, 5] do
			button "Standard Vigenere Cipher", width: 1.0 do
				visit "/standard-vigenere-cipher"
			end
			button "Full Vigenere Cipher", width: 1.0 do
				visit "/full-vigenere-cipher"
			end
			button "Auto-Key Vigenere Cipher", width: 1.0 do
				visit "/autokey-vigenere-cipher"
			end
			button "Extended Vigenere Cipher", width: 1.0 do
				visit "/extended-vigenere-cipher"
			end
			button "Playfair Cipher", width: 1.0 do
				visit "/playfair-cipher"
			end
			button "Affine Cipher", width: 1.0 do
				visit "/affine-cipher"
			end
			button "Enigma Cipher", width: 1.0 do
				visit "/enigma-cipher"
			end
		end
		stack margin: 5, top: 500 do
			inscription "Author: Jauhar Wibisono, 13519160"
			inscription "github.com/Jauhar-Wibisono/various-classic-ciphers"
		end
	end

end

Shoes.app title: "Various Classic Ciphers", width: 600, height: 600