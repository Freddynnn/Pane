# Pane

### Description

TBD
<!-- <img src="public/media/NightSky.png" alt="Constellation Drawing" width="900" > -->


## Table of Contents:

- [Installation/Setup](#installationsetup)
- [Key Functionalities](#key-functionalities)
- [Technologies and Features](#technologies-and-features)


## Installation/Setup

To set up the Unity game project locally, follow these steps:

1. **Clone the Repository**  
   Clone the project repository to your local machine:
   ```bash
   git clone https://github.com/Freddynnn/Pane.git
   ```

2. **Open in Unity**
   - Launch Unity Hub and select the correct version of Unity that matches the project (e.g., Unity 2021.3.0f1 or later).
   - Click on "Open" in Unity Hub and navigate to the cloned project folder to load it in Unity.

3. **Install Dependencies**
   Any additional packages, including those for URP, will automatically download upon opening the project. Make sure you are connected to the internet, as Unity will pull required packages through the Unity Package Manager.

4. **Set Up URP (if not already configured)**
   If URP is not configured:
   - Go to **Edit > Project Settings > Graphics** and select the **Universal Render Pipeline (URP)** asset as the scriptable render pipeline setting.
   - Apply any required settings based on the project requirements.

5. **Play the Game**
   - To start the game in the Unity Editor, simply press the **Play** button in the top toolbar. This will allow you to test the game directly in the editor.
   - Adjust scene views, player settings, and other configurations as needed for testing or development.

**Running the Game as a Standalone Build**

To create a standalone build of the game:

- Go to **File > Build Settings** and select your target platform (Windows, macOS, Linux, etc.).
- Click on **Build and Run** to generate a standalone build you can run outside of the Unity editor.

After building, you can run the standalone version of the game by navigating to the build folder and executing the game file.

## Key Functionalities

**Enemy Lock-on Camera:** 
Camera stack that allows the player to lock on to enemy targets, readjusting the player movement directions to always face the enemy of their chosing. This RayCasting script selects the enemy closes to the camera's center as the main target. 
<div style="text-align: center;">
    <img src="Assets/Media/LockOnCam.gif" alt="Enemy Lock-on">
</div>
<br>

**Optimized Grass Geometry / Compute Shader:** 
This custom shader involves my own implementation of tessellating a mesh and creating new new grass vertices for rendering. This includes various parameters as seen below, to allow for stylistic variations and computational optimisations:

<div style="text-align: center;">
    <img src="Assets/Media/GrassFeatures.gif" alt="Geometry Grass shader">
</div>
<br>


A key optimisation feature is the active culling of grass vertices being rendered outside of our main camera's frustum, which greatly lightens the computation load without detracting from the user's experience. (as seen in the scene view on right).

<div style="text-align: center;">
    <img src="Assets/Media/GrassCull.gif" alt="Geometry Grass shader">
</div>
<br>




**URP Implemented Edge Detection Shader:** 
A stylistic addition to our newly implemented Univeral Rendering Pipeline, this shader has been applied to our rendering asset and serves as a strong step in the game's artistic direction towards its Origami inspired end goal. 
<div style="text-align: center;">
    <img src="Assets/Media/EdgeShader.gif" alt="Edge Detection Shader">
</div>


<br>
<br>

<!-- 
**Intuitive Interface:** 
Enjoy a user-friendly interfaces that make the constellation creation, integration and navigation processes smooth and seamless. This includes constellation hovering & highlighting:  -->




## Technologies and Features

This project utilizes a range of technologies, frameworks, and tools to deliver a rich Unity game experience with custom visual effects and optimized rendering.

### Core Technologies

- **Unity**: A powerful game engine that enables cross-platform development, 3D/2D game rendering, and custom shader support.
- **Universal Render Pipeline (URP)**: URP is implemented in the scene to allow for enhanced graphics and optimized performance across multiple platforms. It enables custom shaders and efficient post-processing effects directly within Unity’s rendering pipeline.

### Graphics and Custom Shaders

- **Custom Shaders (HLSL)**: Custom shaders, developed in HLSL (High-Level Shading Language), add unique visual effects and stylizations tailored to the game’s aesthetic. For instance, an edge-detection shader highlights certain objects in the environment, and an ink-inspired shader achieves a distinctive, stylized look.
- **URP Renderer Features**: Custom renderer features extend URP capabilities, allowing the game to apply and manage effects like edge detection based on camera settings and object layers.

### Development Tools

- **Visual Studio Code (VSCode)**: Used as the primary IDE for scripting and shader development, providing efficient code editing, debugging, and integration with Unity.
- **Git**: Version control to manage code changes and maintain project history, with collaborative workflow support for multiple contributors.
- **GitHub**: Centralized repository for source code, assets, and collaborative project management.


### Asset Handling and Optimization

- **ProBuilder**: Unity’s ProBuilder is used for in-editor level design and quick prototyping of 3D assets directly within Unity.
- **Compression and Optimization**: Asset compression and LOD techniques improve performance, especially on lower-end devices, while maintaining visual quality.



### Testing and Debugging

- **Unity Profiler**: Helps monitor performance and diagnose issues within the game, ensuring optimal frame rates and memory usage.
- **In-Editor Play Mode Testing**: Unity’s Play Mode enables real-time testing of game logic, physics, and visual effects, allowing rapid iteration and debugging.

---

This setup provides a robust foundation for developing a stylized game with custom rendering features, optimized performance, and efficient project management tools.


