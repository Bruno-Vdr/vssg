module commands

pub enum CommandType {
	command
	helper
}

pub interface Command {
	kind    CommandType       // Command type
	name    string            // Command name as used on CLI
	desc    string            // Single line description
	help    string            // Detailed and formated description
	arg_min int               // Minimal argument number expected
	arg_max int               // Maximal argument number expected
	exec    fn (s []string) ! // Command callback.
}

// get is the main command access. It returns a complete list of all available commands
// in map to allow random or sequencial access. All commands must be added in the map,
// in this static method.
pub fn Command.get() map[string]Command {
	mut c := map[string]Command{}

	init := Init.new()
	c[init.name] = init

	add := Add.new()
	c[add.name] = add

	push := Push.new()
	c[push.name] = push

	env := Env.new()
	c[env.name] = env

	show := Show.new()
	c[show.name] = show

	modify := Modify.new()
	c[modify.name] = modify

	remove := Remove.new()
	c[remove.name] = remove

	update := Update.new()
	c[update.name] = update

	rename := Rename.new()
	c[rename.name] = rename

	help := Help.new()
	c[help.name] = help

	drop := Drop.new()
	c[drop.name] = drop

	sync := Sync.new()
	c[sync.name] = sync

	bend := Bend.new()
	c[bend.name] = bend

	pull := Pull.new()
	c[pull.name] = pull

	obfuscate := Obfuscate.new()
	c[obfuscate.name] = obfuscate

	base64 := Base64.new()
	c[base64.name] = base64

	return c
}
