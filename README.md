# ArmorFrame
An addon that consolidates and dynamically displays armor penetration info.   
### Displays:
- Target's armor-relevant debuffs
- Total armor-pen vs. current target
- Calculated net target armor for bosses with well-known values
### Usage:
- Shift click to move the frame
- /af or /armorframe for options
### Ideas to extend to if there is demand:
- Expand to other relevant debuffs for uptime
- Expand class profiles for cross-class debuff uptime for casters

# TODO to implement:
- [x] Implement slash commands
- [ ] Implement frame display
- [ ] Implement hiding/showing based on slash commands
- [ ] Implement ARP updater (changed gear, personal buff, target debuff, target change) (combatratingchange event?)
- [ ] Implement boss armor table, target lookup on table (test with tar haylorn)
- [ ] Implement net boss armor calculations
- [ ] Send chat messages for missing debuffs
