module commands

pub interface Command {
	name    string // Command name as used on CLI
	desc    string // Single line description
	help    string // Detailed and formated description
	arg_min int    // Minimal argument number expected
	arg_max int    // Maximal argument number expected
	exec    fn (s []string) !
}

// get is the main command access. It returns a complete list of all available commands
// in map to allow random or sequencial access. All commands must be added in the map,
// in this static method.
pub fn Command.get() map[string]Command {
	mut c := map[string]Command{}

	i := Init.new()
	c[i.name] = i

	a := Add.new()
	c[a.name] = a

	return c
}
