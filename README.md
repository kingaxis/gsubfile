Batch replace name and content of files which match the patterns

Usage
=====
gsubfile.rb /path/to/config_file /path/to/folder

Configuration
=============
pattern:
    1:
        'SpellingErrrror': 'SpellingError'
        'spelling_errrror': 'spelling_error'
    2:
        'user@example.com': 'member@kingaxis.com'
    3:
        'example.com': 'kingaxis.com'
git_command: false
