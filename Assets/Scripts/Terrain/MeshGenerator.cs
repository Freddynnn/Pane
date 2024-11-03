using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(MeshFilter))]
public class MeshGenerator : MonoBehaviour {
    Mesh mesh;
    Vector3[] vertices;
    int[] triangles;

    public int xSize = 20;
    public int zSize = 20;
    public float noiseHeight = 2f;

    // Start is called before the first frame update
    void Start(){
        mesh = new Mesh();
        GetComponent<MeshFilter>().mesh = mesh;

        CreateShape();
        UpdateMesh();
    }


    void CreateShape(){
    int totalSize = (xSize * 2 + 1) * (zSize * 2 + 1);
    vertices = new Vector3[totalSize];

    int i = 0;
    for (int z = -zSize; z <= zSize; z++){
        for (int x = -xSize; x <= xSize; x++){
            float y = Mathf.PerlinNoise((x + xSize) * 0.3f, (z + zSize) * 0.3f) * noiseHeight;
            vertices[i] = new Vector3(x, y, z);
            i++;
        }
    }

    triangles = new int[xSize * 2 * zSize * 2 * 6];

    int vert = 0;
    int tris = 0;

    for (int z = 0; z < zSize * 2; z++){
        for (int x = 0; x < xSize * 2; x++){
            triangles[tris + 0] = vert + 0;
            triangles[tris + 1] = vert + xSize * 2 + 1;
            triangles[tris + 2] = vert + 1;
            triangles[tris + 3] = vert + 1;
            triangles[tris + 4] = vert + xSize * 2 + 1;
            triangles[tris + 5] = vert + xSize * 2 + 2;

            vert++;
            tris += 6;
        }
        vert++;
    }
}


    void UpdateMesh(){
        mesh.Clear();

        mesh.vertices = vertices;
        mesh.triangles = triangles;

        mesh.RecalculateNormals();

        MeshCollider meshCollider = GetComponent<MeshCollider>();
        if (meshCollider != null) {
            Debug.Log("mesh collider exists");
            meshCollider.sharedMesh = mesh;
        }
    }
   
}
