using System;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.Serialization;

public class SpriteGenerator : MonoBehaviour {

    public GameObject character;

    private void Start() {
        Debug.Log("[SpriteGenerator] START! ---------------------");

        var texture = Resources.Load<Texture2D>("Body/Human");
        var jsonFile = Resources.Load<TextAsset>("Body/Human");

        if (texture == null) {
            Debug.LogError("[SpriteGenerator] Body/Human.png NULL");
            return;
        }

        if (jsonFile == null) {
            Debug.LogError("[SpriteGenerator] Body/Human.json NULL");
            return;
        }

        Debug.LogWarningFormat("[SpriteGenerator] Loaded Body/Human.png and Body/Human.json successfully.");

        var spriteData = JsonUtility.FromJson<SpriteData>(jsonFile.text);

        var sprites = new Dictionary<string, Sprite>();

        Debug.LogWarningFormat("[SpriteGenerator] {0}x parts found", spriteData.parts.Count);

        foreach (var part in spriteData.parts) {
            try {
                float rectX = part.x - part.x_pivot;
                float rectY = spriteData.meta.h - part.y - part.h + part.y_pivot;

                var rect = new Rect(rectX, rectY, part.w, part.h);

                float pivotX = part.x_pivot / part.w;
                float pivotY = (part.y_pivot / part.h - 1) * -1;

                Debug.LogFormat("[SpriteGenerator] <b>({0})</b> pivot x: {1}, pivot y: {2}", part.linkage, pivotX, pivotY);

                var sprite = Sprite.Create(texture, rect, new Vector2(pivotX, pivotY));

                Debug.LogFormat("[SpriteGenerator] <b>({0})</b> Generating Sprite ({1}, {2}), width: {3}, height: {4}, pivot x: {5}, pivot x: {6}", part.linkage, rect.x, rect.y, rect.width, rect.height, sprite.pivot.x, sprite.pivot.y);

                string partName = part.linkage.Replace("_", " ");

                sprite.name = partName;

                sprites[partName] = sprite;

                Debug.LogFormat("[SpriteGenerator] <b>({0})</b> Sprite created and added to dictionary", partName);
            } catch (Exception e) {
                Debug.LogErrorFormat("[SpriteGenerator] <b>({0})</b> Error generating sprite: {1}", part.linkage, e.Message);
            }
        }

        Debug.LogWarningFormat("[SpriteGenerator] {0}x sprites to equip", sprites.Count);

        //Equip Part
        foreach (var keyValuePair in sprites) {
            var find = FindObjectInChildren(character, keyValuePair.Key);

            if (find == null) {
                Debug.LogWarningFormat("[SpriteGenerator] <b>({0})</b> GameObject Not Found", keyValuePair.Key);
                continue;
            }

            var spriteRenderer = find.GetComponent<SpriteRenderer>();

            if (spriteRenderer == null) {
                Debug.LogWarningFormat("[SpriteGenerator] <b>({0})</b> SpriteRenderer Not Found", keyValuePair.Key);
                continue;
            }

            Debug.LogFormat("[SpriteGenerator] <b>({0})</b> Sprite Found and equipped", keyValuePair.Key);

            spriteRenderer.sprite = keyValuePair.Value;
        }

        Debug.Log("[SpriteGenerator] DONE! ---------------------");
    }

    private static GameObject FindObjectInChildren(GameObject parent, string name) {
        if (parent.name == name) {
            return parent;
        }

        for (var i = 0; i < parent.transform.childCount; i++) {
            var child = parent.transform.GetChild(i).gameObject;

            var result = FindObjectInChildren(child, name);

            if (result != null) {
                return result;
            }
        }

        return null;
    }

}

[Serializable]
public class SpriteData {

    public SpriteMeta meta;
    public List<SpriteFrame> parts;

}

[Serializable]
public class SpriteFrame {

    public string linkage;

    public float x;
    public float y;

    public float w;
    public float h;

    public float x_pivot;
    public float y_pivot;

}

[Serializable]
public class SpriteMeta {

    public int w;
    public int h;

}
