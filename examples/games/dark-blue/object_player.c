/*
 * Copyright (c) 2012-2016 Israel Jacquez
 * See LICENSE for details.
 *
 * Israel Jacquez <mrkotfw@gmail.com>
 */

#include <yaul.h>

#include "physics.h"
#include "objects.h"

#define PLAYER_COLOR                    RGB888_TO_RGB555(255, 255, 0)

#define PLAYER_STATE_IDLE               0
#define PLAYER_STATE_WAITING            1
#define PLAYER_STATE_JUMP               2
#define PLAYER_STATE_DEAD               3

static void on_init(struct object *);
static void on_update(struct object *);
static void on_draw(struct object *);
static void on_collision(struct object *, struct object *,
    const struct collider_info *);
static void on_trigger(struct object *, struct object *);

static void m_start(struct object *);
static bool m_dead(struct object *);
static void m_update_polygon(struct object *);
static void m_update_input(struct object *);

static struct collider collider;
static struct rigid_body rigid_body;

struct object_player object_player = {
        .active = true,
        .id = OBJECT_PLAYER_ID,
        .rigid_body = &rigid_body,
        .colliders = {
                NULL
        },
        .on_init = on_init,
        .on_update = on_update,
        .on_draw = on_draw,
        .on_destroy = NULL,
        .on_collision = on_collision,
        .on_trigger = on_trigger,
        .functions = {
                .m_start = m_start,
                .m_dead = m_dead
        },
        .private_functions = {
                .m_update_polygon = m_update_polygon,
                .m_update_input = m_update_input
        }
};

static void
on_init(struct object *this)
{
        /* XXX: There is some serious issues with having a "large" stack
         * frame */
        static struct vdp1_cmdt_local_coord local;

        THIS_PRIVATE_DATA(object_player, state) = PLAYER_STATE_WAITING;
        THIS_PRIVATE_DATA(object_player, last_state) = THIS_PRIVATE_DATA(object_player, state);

        THIS_PRIVATE_DATA(object_player, width) = 8;
        THIS_PRIVATE_DATA(object_player, height) = 16;

        uint16_t width;
        width = THIS_PRIVATE_DATA(object_player, width);
        uint16_t height;
        height = THIS_PRIVATE_DATA(object_player, height);

        THIS(object_player, colliders)[0] = &collider;

        THIS(object_player, rigid_body)->object = this;
        rigid_body_init(THIS(object_player, rigid_body), /* kinematic = */ false);

        THIS(object_player, colliders)[0]->object = this;
        collider_init(THIS(object_player, colliders)[0], /* id = */ -1, width, height,
            /* trigger = */ false, /* fixed = */ false);

        THIS_PRIVATE_DATA(object_player, polygon).cp_color = PLAYER_COLOR;
        THIS_PRIVATE_DATA(object_player, polygon).cp_mode.transparent_pixel = true;
        THIS_PRIVATE_DATA(object_player, polygon).cp_mode.end_code = true;

        physics_object_add((struct object *)this);

        struct cmd_group *cmd_group;
        cmd_group = &THIS_PRIVATE_DATA(object_player, cmd_group);

        cmd_group_init(cmd_group);

        cmd_group->priority = 0;

        local.lc_coord.x = width / 2;
        local.lc_coord.y = SCREEN_HEIGHT - (height / 2);

        cmd_group_add(cmd_group, CMD_GROUP_CMD_TYPE_LOCAL_COORD, &local);
        cmd_group_add(cmd_group, CMD_GROUP_CMD_TYPE_POLYGON,
            &THIS_PRIVATE_DATA(object_player, polygon));
}

static void
on_update(struct object *this)
{
        switch (THIS_PRIVATE_DATA(object_player, state)) {
        case PLAYER_STATE_IDLE:
                THIS_PRIVATE_DATA(object_player, polygon).cp_color = PLAYER_COLOR;

                THIS_CALL_PRIVATE_MEMBER(object_player, update_input);
                break;
        case PLAYER_STATE_WAITING:
                THIS_PRIVATE_DATA(object_player, polygon).cp_color =
                    0x8000 | RGB888_TO_RGB555(255, 0, 0);

                if ((tick % 10) == 0) {
                    /* fix16_vector2_t up = FIX16_VECTOR2_INITIALIZER(0.0f, 500.0f); */
                    /* rigid_body_forces_add(player->rigid_body, &up); */
                }
                break;
        case PLAYER_STATE_JUMP:
                THIS_PRIVATE_DATA(object_player, polygon).cp_color =
                    0x8000 | RGB888_TO_RGB555(0, 255, 0);

                THIS_CALL_PRIVATE_MEMBER(object_player, update_input);
                break;
        case PLAYER_STATE_DEAD:
                /* We're "dead" for 1 frame so game FSM can know we're
                 * dead. Afterwards, go back to the waiting state */
                THIS_PRIVATE_DATA(object_player, state) = PLAYER_STATE_WAITING;
                break;
        default:
                assert(false && "Invalid state");
        }

        THIS_CALL_PRIVATE_MEMBER(object_player, update_polygon);

        cmd_groups_add(&THIS_PRIVATE_DATA(object_player, cmd_group));
}

static void
on_draw(struct object *this __unused)
{
}

static void
on_collision(struct object *this, struct object *other,
    const struct collider_info * info)
{
        (void)sprintf(text, "object->id=%i, other->id=%i, o=%i, d=%i,%i, P=%i,%i\n",
            (int)this->id,
            (int)other->id,
            (int)info->overlap,
            (int)info->direction.x,
            (int)info->direction.y,
            (int)THIS(object_player, transform).pos_int.x,
            (int)THIS(object_player, transform).pos_int.y);
        cons_buffer(text);

        THIS_CALL_PRIVATE_MEMBER(object_player, update_polygon);

        /* Kill player! */
        THIS_PRIVATE_DATA(object_player, state) = PLAYER_STATE_DEAD;
}

static void
on_trigger(struct object *this __unused, struct object *other __unused)
{
}

static void
m_start(struct object *this)
{
        THIS_PRIVATE_DATA(object_player, state) = PLAYER_STATE_IDLE;
}

static bool
m_dead(struct object *this)
{

        return THIS_PRIVATE_DATA(object_player, state) == PLAYER_STATE_DEAD;
}

static void
m_update_polygon(struct object *this)
{
        struct vdp1_cmdt_polygon *polygon;
        polygon = &THIS_PRIVATE_DATA(object_player, polygon);

        uint16_t width;
        width = THIS_PRIVATE_DATA(object_player, width);
        uint16_t height;
        height = THIS_PRIVATE_DATA(object_player, height);

        int16_t x;
        x = THIS(object_player, transform).pos_int.x;
        int16_t y;
        y = THIS(object_player, transform).pos_int.y;

        polygon->cp_vertex.a.x = (width / 2) + x - 1;
        polygon->cp_vertex.a.y = -(height / 2) - y;
        polygon->cp_vertex.b.x = (width / 2) + x - 1;
        polygon->cp_vertex.b.y = (height / 2) - y - 1;
        polygon->cp_vertex.c.x = -(width / 2) + x;
        polygon->cp_vertex.c.y = (height / 2) - y - 1;
        polygon->cp_vertex.d.x = -(width / 2) + x;
        polygon->cp_vertex.d.y = -(height / 2) - y;
}

static void
m_update_input(struct object *this)
{
        int16_vector2_t old_position;
        old_position.x = THIS(object_player, transform).pos_int.x;
        old_position.y = THIS(object_player, transform).pos_int.y;

        int16_vector2_t new_position;
        memcpy(&new_position, &old_position, sizeof(int16_vector2_t));

        if (digital_pad.connected == 1) {
                if (digital_pad.pressed.button.a ||
                    digital_pad.pressed.button.c) {
                        /* fix16_vector2_t up = */
                        /*     FIX16_VECTOR2_INITIALIZER(0.0f, 2.0f * 300.0f); */
                        /* player->private_data.m_state = PLAYER_STATE_JUMP; */
                        /* rigid_body_forces_add(player->rigid_body, &up); */
                }
        }

        THIS(object_player, transform).pos_int.x = new_position.x;
        THIS(object_player, transform).pos_int.y = new_position.y;
}