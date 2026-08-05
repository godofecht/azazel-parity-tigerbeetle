// Azazel builds tigerbeetle's whole VSR library (src/vsr.zig) from source. vsr
// needs the vsr_options module tigerbeetle's build.zig normally generates;
// Azazel injects it as data via option_values (config_verify, git_commit,
// release, release_client_min). Source staged by ./fetch.sh. Lane 0.14.
package build

toolchain: zig: {
	lanes: ["0.14"]
	preferred: "0.14"
}

stdx: #Module & {
	kind: "module"
	root: "vendor/tigerbeetle/src/stdx/stdx.zig"
}

tb_vsr: #Module & {
	kind: "static"
	root: "vendor/tigerbeetle/src/vsr.zig"
	deps: ["stdx"]
	build_options_import: "vsr_options"
	option_values: [
		{name: "config_verify", kind: "bool", bool_value: false},
		{name: "git_commit", kind: "opt_commit"},
		{name: "release", kind: "string", string_value: "0.16.4"},
		{name: "release_client_min", kind: "string", string_value: "0.16.4"},
	]
}
