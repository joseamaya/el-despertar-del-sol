class_name ExampleTuning
extends Resource
## Design values for Example. Tuned in the .tres, never in code (GDD §6.5, §13.2).
## Copy, rename Example -> YourComponent, keep only the values you need.

## One line per value: what it does and which direction "feels" which way.
## Must be > 0: a zero maximum breaks ratios and signals.
@export_range(1.0, 500.0, 1.0) var max_value: float = 100.0
## Units in the suffix help whoever tunes it in the inspector.
@export_range(0.0, 200.0, 0.5, "suffix:/s") var regen_per_second: float = 30.0
@export_range(0.0, 5.0, 0.05, "suffix:s") var regen_delay: float = 0.6
