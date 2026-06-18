#module_parameters(ASSET_FOLDER := "assets");

Sprite :: struct {
    texture: *Texture;
    uvs: [4]Vector2;
}

Sprite_Atlas :: struct {
    texture: Texture;
    rows: int;
    columns: int;
    total: int;
}

load_sprite_atlas_from_file :: (filename: string, rows: int, columns: int) -> Sprite_Atlas {
    assert(rows != 0 || columns != 0, "Atlas cannot have 0 rows or columns!\n");

    atlas: Sprite_Atlas;
    texture, ok := load_texture_from_file(filename);
    assert(ok, "failed to load texture for atlas!");
    assert(texture.height % rows == 0, "Texture height is not divisible by the number of rows passed!\n");
    assert(texture.width % columns == 0, "Texture width is not divisible by the number of columns passed!\n");
    atlas.texture = texture;
    atlas.rows = rows;
    atlas.columns = columns;
    atlas.total = rows * columns;
    return atlas;
}

make_sprite :: (texture: *Texture, uvs: [4]Vector2 = Vector2.[.{0, 1}, .{0, 0}, .{1, 0}, .{1, 1}]) -> Sprite {
    sprite: Sprite;
    sprite.texture = texture;
    sprite.uvs = uvs;
    return sprite;
}

sprite_from_atlas :: (a: *Sprite_Atlas, idx: int) -> Sprite {
    xu: float32 = 1.0 / xx a.columns;
    yu: float32 = 1.0 / xx a.rows;
    top: float32 = ifx idx == 0 then 1 else 1.0 - (cast(float32)(idx / a.columns)) * yu;
    left: float32 = ifx idx == 0 then 0 else xx (idx % a.columns) * xu;
    bot := top - yu;
    right := left + xu;

    sprite: Sprite;
    sprite.texture = *a.texture;
    sprite.uvs = Vector2.[
                          .{left, top},
                          .{left, bot},
                          .{right, bot},
                          .{right, top}];

    return sprite;
}

load_texture_from_file :: (name: string) -> Texture, bool {
    filename := tprint("%/%", ASSET_FOLDER, name);
    result: Texture;
    success := texture_load_from_file(*result, filename);
    return result, success;
}

render_sprite :: (s: Sprite, position: Vector2, size: Vector2, pivot: Vector2 = .{0.0, 0.0}, rotation: float32 = 0, color: Vector4 = .{1, 1, 1, 1}) {
    set_shader_for_images(s.texture);
    p: [4]Vector2;

    origin := position + (pivot * size);

    p[0] = .{-size.x / 2, size.y / 2};
    p[1] = .{-size.x / 2, -size.y / 2};
    p[2] = .{size.x / 2, -size.y / 2};
    p[3] = .{size.x / 2, size.y / 2};

    // Rotation is still a little funky revist when needed, it works fine for origin 0
    for 0..3 {
        p[it] -= pivot * size;
        p[it] = rotate(p[it], rotation);
        p[it] += pivot * size;
        p[it] += position;
    }

    immediate_quad(p[0], p[1], p[2], p[3],
                   color,
                   s.uvs[0], s.uvs[1], s.uvs[2], s.uvs[3]);
}

#import "Simp";
#import "Basic";
#import "Math";
