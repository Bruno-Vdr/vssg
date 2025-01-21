module util

import constants as cst

// This struct embeds dynamical variables that are needed on page generation.
// Some internal runtime values are inserted by default e.g. posts_list_filename for back links
// It consists of a map of string mapping string. This table can be completed at runtime.
pub struct DynVars {
	mut:
	var_map map[string]string // initialized to  map[string]string{}
}

// Create a  DynVars structure containing some common default values.
pub fn DynVars.new() DynVars {
	mut dynvar := DynVars{}
	dynvar.var_map['@posts_list_filename'] = '${cst.posts_list_filename}'
	dynvar.var_map['@topics_list_filename'] = '${cst.topics_list_filename}'

	return dynvar
}

// Insert a new couple of key/var in our table
pub fn (mut d DynVars) add(key string, value string) {
	d.var_map[key] = value
}

// Substitute dynamic variables [@xxxx] from the given string with its associated value.
// There can be 0-n variable in string. Error is return in case of an unknown string.
pub fn (d DynVars) substitute(src string) !string {
	mut ret := src

	mut start := 0
	mut stop := 0
	for {
		start = ret.index_after('[@', start)
		if start == -1 {
			break
		}
		stop = ret.index_after(']', start)
		if stop == -1 {
			break
		}

		// [@ and ] found
		var := ret.substr(start + 1, stop)
		if var !in d.var_map {
			return error('Unknown dynamic variable "${var} in "${src}"')
		}

		start = stop
	}

	// reset src
	ret = src

	for key, value in d.var_map {
		if ret.contains(key) {
			ret = ret.replace('[' + key + ']', value)
		}
	}
	return ret
}
