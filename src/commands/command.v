module commands

pub interface Command {
	name    string // Command name as used on CLI
	desc    string // Single line description
	help    string // Detailed and formated description
	arg_min int    // Minimal argument number expected
	arg_max int    // Maximal argument number expected
}

pub fn Command.get() map[string]Command {
	mut c := map[string]Command{}

	mut i := Init.new()
	c[i.name] = i

	a := Add.new()
	c[a.name] = a
	return c
}
