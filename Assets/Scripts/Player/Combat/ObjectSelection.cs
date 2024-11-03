using UnityEngine;

public class ObjectSelection : MonoBehaviour
{
    private bool isSelected = false;

    private void OnMouseEnter()
    {
        // Cursor is hovering over the object, set it as selected.
        isSelected = true;

        // Update the shader property to indicate selection.
        SetSelected(true);
    }

    private void OnMouseExit()
    {
        // Cursor is no longer hovering, clear the selection.
        isSelected = false;

        // Update the shader property to indicate deselection.
        SetSelected(false);
    }

    private void SetSelected(bool selected)
    {
        Renderer renderer = GetComponent<Renderer>();
        Material material = renderer.material;

        // Update the shader property based on the selection status.
        material.SetInt("_IsSelected", selected ? 1 : 0);
    }
}
