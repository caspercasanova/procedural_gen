# Procedural Generation Project

## Project Overview
This project focuses on generating procedural environments for an online game where players start in a sewer and explore interconnected dungeons. The main goals are to:

- Place buildings or complexes randomly in the environment.
- Connect adjacent complexes using multiple underground tunnels or hallways.
- Dynamically create scripted interactions between players as they explore.

## Current Progress
- **Building Placement**: Implemented random object placement.
- **Pathways**: Started using `Path3D` for connecting objects, but it's still in the early stages.
- **Inspirations**: Followed a tutorial for basic procedural generation mechanics.

## Objectives
1. **Expand Pathway Logic**:
   - Support multiple paths between adjacent complexes.
   - Ensure pathways are realistic and avoid overlaps.
   - Add constraints for tunnel lengths, curves, and intersections.

2. **Dynamic Player Interaction**:
   - Actively connect peers exploring dungeons.
   - Use scripted scenarios to simulate real-life interactions programmatically.

3. **Environment Enhancements**:
   - Include environmental elements like obstacles, treasures, and interactive objects.
   - Add visual variety to buildings and tunnels.

4. **Optimization**:
   - Optimize placement and connection algorithms for large-scale environments.
   - Ensure smooth performance for online multiplayer functionality.

---

## Collaboration Plan

### GitHub Repository
- A repository will be set up for version control and collaboration.  
- All contributors should fork the repo, make changes on branches, and submit pull requests for review.

### Communication
- Active discussions will happen on Discord.
- Use GitHub Issues and Discussions for detailed design ideas, bug reports, and suggestions.


---

## Roadmap
### Phase 1: Foundation
- [x] Set up GitHub repository.
- [ ] Random placement of buildings with bounding box constraints.
- [ ] Basic tunnel connections using `Path3D`.

### Phase 2: Enhanced Path Generation
- [ ] Implement multiple connections between adjacent complexes.
- [ ] Introduce pathfinding logic for optimal tunnel placement.

### Phase 3: Player Interaction
- [ ] Add logic for dynamic peer-to-peer connections in dungeons.
- [ ] Script basic interaction events (e.g., shared puzzles, combat encounters).

### Phase 4: Finalization
- [ ] Test and optimize for multiplayer scenarios.
- [ ] Polish visuals and improve environment design.

---

## Questions & Ideas
- How should we handle overlaps between pathways and objects?
- What algorithm should we use for pathfinding and connectivity? (Dijkstra, A*, or custom?)
- Any suggestions for making the interactions between players more engaging?

---

Feel free to adapt this template to your project’s specific needs. Once you’ve set up the GitHub repo, you can use this as the `README.md` file to document your progress and invite input from collaborators.


---
Contributors:
_anubix
crazycunt
