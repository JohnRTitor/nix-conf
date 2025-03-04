<?php

namespace nixos {
	function adminer_object() {
		require_once(__DIR__ . '/plugins/plugin.php');

		$plugins = [];
		if (file_exists(__DIR__ . '/plugins.json')) {
			$names = json_decode(file_get_contents(__DIR__ . '/plugins.json'), true);

			foreach ($names as $name) {
				$plugin = __DIR__ . '/plugins/' . $name . '.php';
				if (is_readable($plugin)) {
					require($plugin);

					preg_match_all('/(\w+)/', $name, $matches);

					$className = 'Adminer'. implode('', array_map('ucfirst', $matches[1]));

					$plugins[] = new $className;
				}
			}
		}
		// Add AdminerTheme at the end of the plugins array
		require_once(__DIR__ . '/plugins/AdminerTheme.php');
        // Color variant can by specified in constructor parameter.
        // or passed without a parameter to use the default color
        // new \AdminerTheme("default-orange"),
        // new \AdminerTheme("default-blue"),
        // new \AdminerTheme("default-green", ["192.168.0.1" => "default-orange"]),
		$plugins[] = new \AdminerTheme("default-green");

		return new \AdminerPlugin($plugins);
	}
}

namespace {
	function adminer_object() {
		return \nixos\adminer_object();
	}

	require(__DIR__ . '/adminer.php');
}
