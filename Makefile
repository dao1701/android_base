
GODOT := godot

# Output files
PCK_FILE := project.pck
ENCRYPTED_PCK := project.encrypted.pck
KEY := 27abb669d265e96c62aa16d412ececb4820ba8ccd8267e76b34d1801856f8781
IV := be63253308a2b0811dd6b287ec1b0b36

# create PCK file
create-pck: 
	$(GODOT) --export-pack "Android" $(PCK_FILE) . --headless
	@echo "PCK file created as $(PCK_FILE)"
# Create encrypted PCK file
encrypt: $(PCK_FILE)
	@if [ -z "$(KEY)" ]; then \
		echo "Error: KEY environment variable not set. Use: make encrypt KEY=your_encryption_key IV=your_iv"; \
		exit 1; \
	fi
	@if [ -z "$(IV)" ]; then \
		echo "Error: IV environment variable not set. Use: make encrypt KEY=your_encryption_key IV=your_iv"; \
		exit 1; \
	fi
	openssl enc -aes-256-cbc -in $(PCK_FILE) -out $(ENCRYPTED_PCK) -K $(KEY) -iv $(IV) -nosalt
	@echo "Encrypted PCK created as $(ENCRYPTED_PCK)"
# Decrypt encrypted PCK file
decrypt:
	openssl enc -d -aes-256-cbc -in $(ENCRYPTED_PCK) -out $(PCK_FILE) -K $(KEY) -iv $(IV) -nosalt
	@echo "Decrypted PCK created as $(PCK_FILE)"
# Clean build artifacts
clean:
	rm -f $(PCK_FILE) $(ENCRYPTED_PCK) $(GODOT)

.PHONY: all encrypt clean create-pck
