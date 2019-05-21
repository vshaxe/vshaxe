//@ts-check

'use strict';

const path = require('path');

/**@type {import('webpack').Configuration}*/
const config = {
	target: 'node',
	entry: './bin/client.js',
	output: {
		path: path.resolve(__dirname, 'bin'),
		filename: 'client.js',
		libraryTarget: 'commonjs2',
		devtoolModuleFilenameTemplate: '../[resource-path]'
	},
	devtool: 'source-map',
	externals: {
		vscode: 'commonjs vscode'
	},
	resolve: {
		extensions: ['.js']
	},
	module: {
		rules: [
			{
				test: /\.ts$/,
				exclude: /node_modules/
			}
		]
	}
};
module.exports = config;