fs = require 'fs'
path = require 'path'
readfile = (filename) -> fs.readFileSync path.dirname(__filename) + filename, encoding: 'utf8'
BEM_CONTENT = """
	#{readfile '/bemto.jade'}

	mixin i(data1, data2, data3)
		- var data = {}
		- var redefines = []
		- if (typeof data1 === 'object') redefines.push(data1)
		- if (typeof data2 === 'object') redefines.push(data2)
		- if (typeof data3 === 'object') redefines.push(data3)
		- for (var i in redefines)
			- for (var k in redefines[i])
				- if (redefines[i].hasOwnProperty(k))
					- data[k] = redefines[i][k]

		- data._bemto_chain = bemto_chain.slice()
		- data._bemto_chain_contexts = bemto_chain_contexts.slice()
		- data._bemto_regex_element = bemto_regex_element
		- var blockName = bemto_chain[bemto_chain.length-1]
		!= renderBlock(blockName, data)

	if _bemto_chain
		- bemto_chain = _bemto_chain
		- bemto_chain_contexts = _bemto_chain_contexts
		- bemto_regex_element = _bemto_regex_element
"""

module.exports = (next) ->
	@on "readFile", (file) =>
		if file.srcExtname is '.jade'
			for line in file.source.split("\n")
				return if ///^extends\s///.test line
			file.source = BEM_CONTENT + "\n\n" + file.source
			file.source = file.source.replace ///\t///g, '  '
			@modified file
	next()