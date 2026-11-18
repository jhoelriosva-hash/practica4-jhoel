$code = @'
using System;
using System.IO;
using System.Collections.Generic;
using System.Text;

public class GlbModel {
    private List<float> positions = new List<float>();
    private List<float> normals = new List<float>();
    private List<float> colors = new List<float>();
    private List<ushort> indices = new List<ushort>();

    public void AddTriangle(
        float[] p1, float[] p2, float[] p3,
        float[] n1, float[] n2, float[] n3,
        float[] c
    ) {
        ushort baseIdx = (ushort)(positions.Count / 3);
        
        positions.AddRange(p1);
        positions.AddRange(p2);
        positions.AddRange(p3);

        normals.AddRange(n1);
        normals.AddRange(n2);
        normals.AddRange(n3);

        colors.AddRange(c);
        colors.AddRange(c);
        colors.AddRange(c);

        indices.Add(baseIdx);
        indices.Add((ushort)(baseIdx + 1));
        indices.Add((ushort)(baseIdx + 2));
    }

    public void AddEllipsoid(float cx, float cy, float cz, float rx, float ry, float rz, float[] col, int latBands = 12, int longBands = 16, float topTaper = 1.0f) {
        for (int i = 0; i < latBands; i++) {
            float theta1 = (float)Math.PI * i / latBands;
            float theta2 = (float)Math.PI * (i + 1) / latBands;

            float sinT1 = (float)Math.Sin(theta1);
            float cosT1 = (float)Math.Cos(theta1);
            float sinT2 = (float)Math.Sin(theta2);
            float cosT2 = (float)Math.Cos(theta2);

            // egg taper factor
            float taper1 = 1.0f - (cosT1 > 0 ? (1.0f - topTaper) * cosT1 : 0f);
            float taper2 = 1.0f - (cosT2 > 0 ? (1.0f - topTaper) * cosT2 : 0f);

            for (int j = 0; j < longBands; j++) {
                float phi1 = (float)(2 * Math.PI * j / longBands);
                float phi2 = (float)(2 * Math.PI * (j + 1) / longBands);

                float cosP1 = (float)Math.Cos(phi1);
                float sinP1 = (float)Math.Sin(phi1);
                float cosP2 = (float)Math.Cos(phi2);
                float sinP2 = (float)Math.Sin(phi2);

                float[] p00 = { cx + rx * sinT1 * cosP1 * taper1, cy + ry * cosT1, cz + rz * sinT1 * sinP1 * taper1 };
                float[] p10 = { cx + rx * sinT2 * cosP1 * taper2, cy + ry * cosT2, cz + rz * sinT2 * sinP1 * taper2 };
                float[] p01 = { cx + rx * sinT1 * cosP2 * taper1, cy + ry * cosT1, cz + rz * sinT1 * sinP2 * taper1 };
                float[] p11 = { cx + rx * sinT2 * cosP2 * taper2, cy + ry * cosT2, cz + rz * sinT2 * sinP2 * taper2 };

                float[] n00 = { sinT1 * cosP1, cosT1, sinT1 * sinP1 };
                float[] n10 = { sinT2 * cosP1, cosT2, sinT2 * sinP1 };
                float[] n01 = { sinT1 * cosP2, cosT1, sinT1 * sinP2 };
                float[] n11 = { sinT2 * cosP2, cosT2, sinT2 * sinP2 };

                AddTriangle(p00, p10, p01, n00, n10, n01, col);
                AddTriangle(p01, p10, p11, n01, n10, n11, col);
            }
        }
    }

    public void AddBox(float cx, float cy, float cz, float sx, float sy, float sz, float[] col) {
        float hx = sx / 2f, hy = sy / 2f, hz = sz / 2f;
        
        // Front (+Z)
        AddQuad(
            new float[] { cx - hx, cy - hy, cz + hz },
            new float[] { cx + hx, cy - hy, cz + hz },
            new float[] { cx + hx, cy + hy, cz + hz },
            new float[] { cx - hx, cy + hy, cz + hz },
            new float[] { 0, 0, 1 }, col
        );
        // Back (-Z)
        AddQuad(
            new float[] { cx + hx, cy - hy, cz - hz },
            new float[] { cx - hx, cy - hy, cz - hz },
            new float[] { cx - hx, cy + hy, cz - hz },
            new float[] { cx + hx, cy + hy, cz - hz },
            new float[] { 0, 0, -1 }, col
        );
        // Top (+Y)
        AddQuad(
            new float[] { cx - hx, cy + hy, cz + hz },
            new float[] { cx + hx, cy + hy, cz + hz },
            new float[] { cx + hx, cy + hy, cz - hz },
            new float[] { cx - hx, cy + hy, cz - hz },
            new float[] { 0, 1, 0 }, col
        );
        // Bottom (-Y)
        AddQuad(
            new float[] { cx - hx, cy - hy, cz - hz },
            new float[] { cx + hx, cy - hy, cz - hz },
            new float[] { cx + hx, cy - hy, cz + hz },
            new float[] { cx - hx, cy - hy, cz + hz },
            new float[] { 0, -1, 0 }, col
        );
        // Right (+X)
        AddQuad(
            new float[] { cx + hx, cy - hy, cz + hz },
            new float[] { cx + hx, cy - hy, cz - hz },
            new float[] { cx + hx, cy + hy, cz - hz },
            new float[] { cx + hx, cy + hy, cz + hz },
            new float[] { 1, 0, 0 }, col
        );
        // Left (-X)
        AddQuad(
            new float[] { cx - hx, cy - hy, cz - hz },
            new float[] { cx - hx, cy - hy, cz + hz },
            new float[] { cx - hx, cy + hy, cz + hz },
            new float[] { cx - hx, cy + hy, cz - hz },
            new float[] { -1, 0, 0 }, col
        );
    }

    public void AddQuad(float[] p1, float[] p2, float[] p3, float[] p4, float[] n, float[] c) {
        AddTriangle(p1, p2, p3, n, n, n, c);
        AddTriangle(p1, p3, p4, n, n, n, c);
    }

    public void AddCylinder(float cx, float cy, float cz, float rTop, float rBottom, float height, float[] col, int segments = 12) {
        float hh = height / 2f;
        for (int i = 0; i < segments; i++) {
            float phi1 = (float)(2 * Math.PI * i / segments);
            float phi2 = (float)(2 * Math.PI * (i + 1) / segments);

            float cos1 = (float)Math.Cos(phi1), sin1 = (float)Math.Sin(phi1);
            float cos2 = (float)Math.Cos(phi2), sin2 = (float)Math.Sin(phi2);

            float[] pTop1 = { cx + rTop * cos1, cy + hh, cz + rTop * sin1 };
            float[] pTop2 = { cx + rTop * cos2, cy + hh, cz + rTop * sin2 };
            float[] pBot1 = { cx + rBottom * cos1, cy - hh, cz + rBottom * sin1 };
            float[] pBot2 = { cx + rBottom * cos2, cy - hh, cz + rBottom * sin2 };

            float[] n1 = { cos1, 0, sin1 };
            float[] n2 = { cos2, 0, sin2 };

            AddTriangle(pTop1, pBot1, pTop2, n1, n1, n2, col);
            AddTriangle(pTop2, pBot1, pBot2, n2, n1, n2, col);

            // caps
            if (rTop > 0.001f) {
                float[] centerTop = { cx, cy + hh, cz };
                float[] normTop = { 0, 1, 0 };
                AddTriangle(centerTop, pTop1, pTop2, normTop, normTop, normTop, col);
            }
            if (rBottom > 0.001f) {
                float[] centerBot = { cx, cy - hh, cz };
                float[] normBot = { 0, -1, 0 };
                AddTriangle(centerBot, pBot2, pBot1, normBot, normBot, normBot, col);
            }
        }
    }

    public void AddCone(float cx, float cy, float cz, float baseRadius, float length, float[] dir, float[] col, int segments = 10) {
        // cone with base at (cx, cy, cz) pointing along dir
        float tipX = cx + dir[0] * length;
        float tipY = cy + dir[1] * length;
        float tipZ = cz + dir[2] * length;

        for (int i = 0; i < segments; i++) {
            float a1 = (float)(2 * Math.PI * i / segments);
            float a2 = (float)(2 * Math.PI * (i + 1) / segments);

            // perpendicular vectors
            float cos1 = (float)Math.Cos(a1) * baseRadius;
            float sin1 = (float)Math.Sin(a1) * baseRadius;
            float cos2 = (float)Math.Cos(a2) * baseRadius;
            float sin2 = (float)Math.Sin(a2) * baseRadius;

            float[] p1 = { cx + cos1, cy + sin1, cz };
            float[] p2 = { cx + cos2, cy + sin2, cz };
            float[] pTip = { tipX, tipY, tipZ };

            float[] n = { 0, 0, dir[2] };
            AddTriangle(p1, pTip, p2, n, n, n, col);
        }
    }

    public byte[] BuildGlb(string modelName) {
        int vertCount = positions.Count / 3;
        int indexCount = indices.Count;

        float minX = float.MaxValue, minY = float.MaxValue, minZ = float.MaxValue;
        float maxX = float.MinValue, maxY = float.MinValue, maxZ = float.MinValue;

        for (int i = 0; i < positions.Count; i += 3) {
            float x = positions[i], y = positions[i+1], z = positions[i+2];
            if (x < minX) minX = x; if (x > maxX) maxX = x;
            if (y < minY) minY = y; if (y > maxY) maxY = y;
            if (z < minZ) minZ = z; if (z > maxZ) maxZ = z;
        }

        using (MemoryStream binMs = new MemoryStream())
        using (BinaryWriter bw = new BinaryWriter(binMs)) {
            int posOffset = 0;
            int posLen = vertCount * 12;
            for (int i = 0; i < positions.Count; i++) bw.Write(positions[i]);

            int normOffset = (int)binMs.Position;
            int normLen = vertCount * 12;
            for (int i = 0; i < normals.Count; i++) bw.Write(normals[i]);

            int colOffset = (int)binMs.Position;
            int colLen = vertCount * 16;
            for (int i = 0; i < colors.Count; i++) bw.Write(colors[i]);

            int idxOffset = (int)binMs.Position;
            int idxLen = indexCount * 2;
            for (int i = 0; i < indices.Count; i++) bw.Write(indices[i]);

            while (binMs.Length % 4 != 0) bw.Write((byte)0);

            byte[] binBytes = binMs.ToArray();

            string json = "{" +
                "\"asset\":{\"version\":\"2.0\",\"generator\":\"Avicola 3D Studio\"}," +
                "\"scene\":0," +
                "\"scenes\":[{\"nodes\":[0]}]," +
                "\"nodes\":[{\"mesh\":0,\"name\":\"" + modelName + "\"}]," +
                "\"meshes\":[{\"primitives\":[{" +
                    "\"attributes\":{\"POSITION\":0,\"NORMAL\":1,\"COLOR_0\":2}," +
                    "\"indices\":3," +
                    "\"material\":0" +
                "}]}]," +
                "\"materials\":[{\"pbrMetallicRoughness\":{\"metallicFactor\":0.15,\"roughnessFactor\":0.55},\"doubleSided\":true}]," +
                "\"accessors\":[" +
                    "{\"bufferView\":0,\"componentType\":5126,\"count\":" + vertCount + ",\"type\":\"VEC3\",\"max\":[" + maxX.ToString("R", System.Globalization.CultureInfo.InvariantCulture) + "," + maxY.ToString("R", System.Globalization.CultureInfo.InvariantCulture) + "," + maxZ.ToString("R", System.Globalization.CultureInfo.InvariantCulture) + "],\"min\":[" + minX.ToString("R", System.Globalization.CultureInfo.InvariantCulture) + "," + minY.ToString("R", System.Globalization.CultureInfo.InvariantCulture) + "," + minZ.ToString("R", System.Globalization.CultureInfo.InvariantCulture) + "]}," +
                    "{\"bufferView\":1,\"componentType\":5126,\"count\":" + vertCount + ",\"type\":\"VEC3\"}," +
                    "{\"bufferView\":2,\"componentType\":5126,\"count\":" + vertCount + ",\"type\":\"VEC4\"}," +
                    "{\"bufferView\":3,\"componentType\":5123,\"count\":" + indexCount + ",\"type\":\"SCALAR\"}" +
                "]," +
                "\"bufferViews\":[" +
                    "{\"buffer\":0,\"byteOffset\":" + posOffset + ",\"byteLength\":" + posLen + ",\"target\":34962}," +
                    "{\"buffer\":0,\"byteOffset\":" + normOffset + ",\"byteLength\":" + normLen + ",\"target\":34962}," +
                    "{\"buffer\":0,\"byteOffset\":" + colOffset + ",\"byteLength\":" + colLen + ",\"target\":34962}," +
                    "{\"buffer\":0,\"byteOffset\":" + idxOffset + ",\"byteLength\":" + idxLen + ",\"target\":34963}" +
                "]," +
                "\"buffers\":[{\"byteLength\":" + binBytes.Length + "}]" +
            "}";

            byte[] jsonBytes = Encoding.UTF8.GetBytes(json);
            int jsonPad = (4 - (jsonBytes.Length % 4)) % 4;
            byte[] paddedJson = new byte[jsonBytes.Length + jsonPad];
            Array.Copy(jsonBytes, paddedJson, jsonBytes.Length);
            for (int i = 0; i < jsonPad; i++) paddedJson[jsonBytes.Length + i] = 0x20;

            int totalLen = 12 + 8 + paddedJson.Length + 8 + binBytes.Length;

            using (MemoryStream glbMs = new MemoryStream())
            using (BinaryWriter gw = new BinaryWriter(glbMs)) {
                gw.Write((uint)0x46546C67);
                gw.Write((uint)2);
                gw.Write((uint)totalLen);

                gw.Write((uint)paddedJson.Length);
                gw.Write((uint)0x4E4F534A);
                gw.Write(paddedJson);

                gw.Write((uint)binBytes.Length);
                gw.Write((uint)0x004E4942);
                gw.Write(binBytes);

                return glbMs.ToArray();
            }
        }
    }
}
'@

Add-Type -TypeDefinition $code

$outDir = "C:\Users\jhoel\Downloads\emprendimiento\modelos"

# 1. POLLO ENTERO FRESCO
$pollo = New-Object GlbModel
$colWhite = @(0.96, 0.95, 0.92, 1.0)
$colCrest = @(0.88, 0.18, 0.18, 1.0)
$colBeak = @(0.98, 0.65, 0.08, 1.0)
$colEye = @(0.12, 0.12, 0.14, 1.0)
$colLeg = @(0.95, 0.60, 0.05, 1.0)

# Body (plump ellipsoid)
$pollo.AddEllipsoid(0.0, 0.0, 0.0, 0.65, 0.60, 0.85, $colWhite, 16, 20)
# Chest protrusion
$pollo.AddEllipsoid(0.0, 0.15, 0.45, 0.45, 0.45, 0.45, $colWhite, 12, 16)
# Head
$pollo.AddEllipsoid(0.0, 0.75, 0.55, 0.35, 0.40, 0.38, $colWhite, 14, 18)
# Comb (Cresta) 3 bumps
$pollo.AddEllipsoid(0.0, 1.15, 0.45, 0.08, 0.18, 0.15, $colCrest, 8, 10)
$pollo.AddEllipsoid(0.0, 1.25, 0.60, 0.08, 0.22, 0.15, $colCrest, 8, 10)
$pollo.AddEllipsoid(0.0, 1.18, 0.75, 0.08, 0.18, 0.15, $colCrest, 8, 10)
# Wattles (Barbillas)
$pollo.AddEllipsoid(-0.06, 0.55, 0.82, 0.06, 0.14, 0.08, $colCrest, 8, 10)
$pollo.AddEllipsoid(0.06, 0.55, 0.82, 0.06, 0.14, 0.08, $colCrest, 8, 10)
# Beak (Pico)
$pollo.AddCone(0.0, 0.72, 0.85, 0.12, 0.28, @(0.0, -0.2, 1.0), $colBeak, 10)
# Eyes
$pollo.AddEllipsoid(-0.25, 0.82, 0.68, 0.06, 0.06, 0.06, $colEye, 8, 8)
$pollo.AddEllipsoid(0.25, 0.82, 0.68, 0.06, 0.06, 0.06, $colEye, 8, 8)
# Wings
$pollo.AddEllipsoid(-0.62, 0.10, -0.05, 0.15, 0.35, 0.55, $colWhite, 10, 14)
$pollo.AddEllipsoid(0.62, 0.10, -0.05, 0.15, 0.35, 0.55, $colWhite, 10, 14)
# Tail
$pollo.AddEllipsoid(0.0, 0.45, -0.80, 0.18, 0.45, 0.25, $colWhite, 10, 12)
# Legs
$pollo.AddCylinder(-0.25, -0.65, 0.10, 0.04, 0.04, 0.40, $colLeg, 8)
$pollo.AddCylinder(0.25, -0.65, 0.10, 0.04, 0.04, 0.40, $colLeg, 8)
# Feet (toes)
$pollo.AddBox(-0.25, -0.85, 0.20, 0.20, 0.03, 0.25, $colLeg)
$pollo.AddBox(0.25, -0.85, 0.20, 0.20, 0.03, 0.25, $colLeg)

[System.IO.File]::WriteAllBytes("$outDir\pollo_entero.glb", $pollo.BuildGlb("PolloEntero"))
Write-Host "Pollo Entero GLB generated!"


# 2. CUBETA DE HUEVOS
$cubeta = New-Object GlbModel
$colCarton = @(0.72, 0.66, 0.56, 1.0)
$colEgg1 = @(0.94, 0.86, 0.74, 1.0)
$colEgg2 = @(0.90, 0.78, 0.65, 1.0)
$colEgg3 = @(0.97, 0.92, 0.85, 1.0)

# Carton Base tray
$cubeta.AddBox(0.0, -0.15, 0.0, 1.8, 0.18, 1.4, $colCarton)
# Carton rim
$cubeta.AddBox(0.0, 0.0, 0.0, 1.9, 0.12, 1.5, $colCarton)

# Eggs 3x2 grid
$eggCols = @($colEgg1, $colEgg2, $colEgg3, $colEgg2, $colEgg1, $colEgg3)
$idx = 0
for ($ix = -1; $ix -le 1; $ix++) {
    for ($iz = -0.5; $iz -le 0.5; $iz += 1.0) {
        $c = $eggCols[$idx % $eggCols.Count]
        # Egg shape with top taper
        $cubeta.AddEllipsoid(($ix * 0.55), 0.22, ($iz * 0.55), 0.22, 0.32, 0.22, $c, 14, 16, 0.68)
        $idx++
    }
}
[System.IO.File]::WriteAllBytes("$outDir\cubeta_huevos.glb", $cubeta.BuildGlb("CubetaHuevos"))
Write-Host "Cubeta Huevos GLB generated!"


# 3. MUSLOS DE POLLO
$muslo = New-Object GlbModel
$colRoast = @(0.85, 0.46, 0.16, 1.0)
$colRoastDark = @(0.68, 0.32, 0.10, 1.0)
$colBone = @(0.95, 0.93, 0.88, 1.0)
$colHerb = @(0.20, 0.65, 0.22, 1.0)

# Main drumstick 1
$muslo.AddEllipsoid(0.0, 0.20, 0.10, 0.48, 0.62, 0.44, $colRoast, 16, 20)
$muslo.AddEllipsoid(0.05, 0.35, 0.05, 0.40, 0.35, 0.38, $colRoastDark, 12, 16)
# Bone extending downward
$muslo.AddCylinder(0.0, -0.45, 0.10, 0.08, 0.08, 0.55, $colBone, 10)
# Bone knobs
$muslo.AddEllipsoid(-0.08, -0.72, 0.10, 0.11, 0.11, 0.11, $colBone, 10, 10)
$muslo.AddEllipsoid(0.08, -0.72, 0.10, 0.11, 0.11, 0.11, $colBone, 10, 10)
# Parsley garnish leaf on top
$muslo.AddEllipsoid(0.0, 0.70, 0.12, 0.15, 0.04, 0.12, $colHerb, 8, 8)
[System.IO.File]::WriteAllBytes("$outDir\muslos_pollo.glb", $muslo.BuildGlb("MuslosPollo"))
Write-Host "Muslos Pollo GLB generated!"


# 4. PECHUGA ESPECIAL
$pechuga = New-Object GlbModel
$colBreast = @(0.97, 0.84, 0.80, 1.0)
$colBreastGloss = @(0.99, 0.90, 0.86, 1.0)

# Curved plump chicken breast fillet
$pechuga.AddEllipsoid(0.0, 0.0, 0.0, 0.85, 0.32, 0.55, $colBreast, 16, 20, 0.65)
$pechuga.AddEllipsoid(0.20, 0.06, 0.0, 0.55, 0.26, 0.42, $colBreastGloss, 14, 18, 0.75)
# Garnish herbs on top
$pechuga.AddEllipsoid(-0.15, 0.28, 0.05, 0.12, 0.03, 0.08, $colHerb, 8, 8)
$pechuga.AddEllipsoid(0.05, 0.29, -0.05, 0.10, 0.03, 0.09, $colHerb, 8, 8)
[System.IO.File]::WriteAllBytes("$outDir\pechuga.glb", $pechuga.BuildGlb("PechugaPollo"))
Write-Host "Pechuga GLB generated!"


# 5. ALITAS DE POLLO
$alitas = New-Object GlbModel
$colWingCrisp = @(0.86, 0.48, 0.15, 1.0)
$colGlaze = @(0.72, 0.35, 0.08, 1.0)

# Wing segment 1 (Drumette)
$alitas.AddEllipsoid(-0.35, 0.0, 0.0, 0.32, 0.45, 0.28, $colWingCrisp, 14, 18)
$alitas.AddCylinder(-0.35, -0.45, 0.0, 0.06, 0.06, 0.25, $colBone, 8)
# Wing segment 2 (Wingette / Flat) angled
$alitas.AddEllipsoid(0.30, 0.20, 0.0, 0.45, 0.26, 0.24, $colWingCrisp, 14, 18)
$alitas.AddEllipsoid(0.25, 0.25, 0.05, 0.32, 0.18, 0.20, $colGlaze, 12, 14)
# Wing tip
$alitas.AddEllipsoid(0.75, 0.35, 0.0, 0.18, 0.12, 0.12, $colWingCrisp, 10, 12)
[System.IO.File]::WriteAllBytes("$outDir\alitas.glb", $alitas.BuildGlb("AlitasPollo"))
Write-Host "Alitas GLB generated!"

