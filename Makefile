fmt:
	echo "===> Formatting"
	stylua lua/ --config-path=.stylua.toml

lint:
	echo "===> Linting with luacheck"
	luacheck lua/ --globals vim
	echo "===> Linting with selene"
	selene lua/

pr-ready: fmt lint
