#!/usr/bin/env python3
"""
EnemyX V1.1 Inventory Script
Lists all public exports, events, NUI callbacks, framework functions, config entries, and entity lifecycle paths
"""

import os
import re

class Inventory:
    def __init__(self):
        self.base_path = "E:/fivem_server/SERVERS/Standalone server/txData/FiveMBasicServerCFXDefault_C78E24.base/resources/enemyx"

    def run(self):
        print("=" * 80)
        print("EnemyX V1.1 Inventory")
        print("=" * 80)
        print()

        self.inventory_exports()
        self.inventory_events()
        self.inventory_nui_callbacks()
        self.inventory_framework_functions()
        self.inventory_config_entries()
        self.inventory_entity_lifecycle()

    def _read_file(self, path):
        try:
            with open(path, 'r', encoding='utf-8') as f:
                return f.read()
        except Exception as e:
            print(f"Error reading {path}: {e}")
            return None

    def inventory_exports(self):
        print("PUBLIC EXPORTS")
        print("-" * 20)
        fxmanifest_path = os.path.join(self.base_path, "fxmanifest.lua")
        content = self._read_file(fxmanifest_path)
        if content:
            # Extract exports block
            exports_start = content.find("exports {")
            if exports_start != -1:
                exports_end = content.find("}", exports_start)
                if exports_end != -1:
                    exports_block = content[exports_start:exports_end+1]
                    # Extract each export line
                    exports = re.findall(r"'([^']+)'", exports_block)
                    for export in exports:
                        print(f"  - {export}")
        print()

    def inventory_events(self):
        print("EVENTS (from shared/constants.lua)")
        print("-" * 40)
        constants_path = os.path.join(self.base_path, "shared/constants.lua")
        content = self._read_file(constants_path)
        if content:
            # Find the Events table
            events_start = content.find("Events = {")
            if events_start != -1:
                events_end = content.find("}", events_start)
                if events_end != -1:
                    events_block = content[events_start:events_end+1]
                    # Extract each event
                    events = re.findall(r"([%w_]+) = \"[%w_]+\"", events_block)
                    for event in events:
                        print(f"  - {event}")
        print()

    def inventory_nui_callbacks(self):
        print("NUI CALLBACKS (from admin module)")
        print("-" * 40)
        admin_path = os.path.join(self.base_path, "modules/admin/main.lua")
        content = self._read_file(admin_path)
        if content:
            # Find all RegisterNUICallback lines - simple string search
            callbacks = []
            lines = content.split('\n')
            for line in lines:
                if "RegisterNUICallback(" in line:
                    # Extract the part inside the quotes after RegisterNUICallback(
                    start_pos = line.find("RegisterNUICallback(")
                    if start_pos != -1:
                        # Find the opening quote after the opening parenthesis
                        quote_pos = line.find("'", start_pos)
                        if quote_pos != -1:
                            # Find the closing quote
                            end_quote_pos = line.find("'", quote_pos + 1)
                            if end_quote_pos != -1:
                                callback = line[quote_pos + 1:end_quote_pos]
                                callbacks.append(callback)
            for callback in callbacks:
                print(f"  - {callback}")
        print()

    def inventory_framework_functions(self):
        print("FRAMEWORK ADAPTER FUNCTIONS (interface)")
        print("-" * 50)
        # We know the interface from the adapters, but let's list one adapter as example
        adapter_path = os.path.join(self.base_path, "adapters/standalone.lua")
        content = self._read_file(adapter_path)
        if content:
            # Extract function names (simplistic)
            functions = re.findall(r"function Framework%.([%w_]+)", content)
            for func in functions:
                print(f"  - {func}")
        print()

    def inventory_config_entries(self):
        print("CONFIGURATION ENTRIES (from config files)")
        print("-" * 50)
        config_dir = os.path.join(self.base_path, "config")
        config_files = ["config.lua", "enemies.lua", "weapons.lua", "vehicles.lua", "groups.lua", "zones.lua", "encounters.lua"]
        for file_name in config_files:
            path = os.path.join(config_dir, file_name)
            content = self._read_file(path)
            if content:
                print(f"  {file_name}:")
                # Extract top-level keys (simple approach)
                lines = content.split('\n')
                for line in lines:
                    line = line.strip()
                    # Look for lines like "key = {" or "key = "
                    if ' = {' in line and not line.startswith('--'):
                        key = line.split(' = {')[0].strip()
                        if key and not key.startswith('return') and key not in ['Framework', 'Debug', 'Performance', 'AutoDirector', 'Defaults']:
                            print(f"    - {key}")
                    elif ' = ' in line and not line.startswith('--') and not '{' in line and not '}' in line:
                        # For simple assignments like Debug = false
                        key = line.split(' = ')[0].strip()
                        if key and not key.startswith('return'):
                            print(f"    - {key}")
        print()

    def inventory_entity_lifecycle(self):
        print("ENTITY LIFECYCLE PATHS")
        print("-" * 30)
        # We'll look at entity_manager.lua and the handlers
        files = [
            "core/entity_manager.lua",
            "server/npc_handler.lua",
            "client/npc_handler.lua",
            "server/zone_handler.lua",
            "client/zone_handler.lua"
        ]
        for file_path in files:
            full_path = os.path.join(self.base_path, file_path)
            content = self._read_file(full_path)
            if content:
                print(f"  {file_path}:")
                # Look for functions that create/delete entities - simpler approach
                lines = content.split('\n')
                for line in lines:
                    line = line.strip()
                    if line.startswith('function ') and ('Create' in line or 'Delete' in line or 'Remove' in line or 'Spawn' in line):
                        # Extract function name
                        if ':' in line:
                            # Class method format: function Class:Method
                            func_part = line.split(':')[1].split('(')[0].strip()
                        else:
                            # Regular function format: function FunctionName
                            func_part = line.split(' ')[1].split('(')[0].strip()
                        if func_part:
                            print(f"    - {func_part}")
        print()

if __name__ == "__main__":
    inventory = Inventory()
    inventory.run()