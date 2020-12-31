import React, { useState }  from 'react';
import styles from './playroom.module.css';
import WerewolfPlayroom from '../werewolf/werewolfPlayroom/werewolfPlayroom';
import NextRoundPlayroom from '../next-round/nextroundPlayroom/nextroundPlayroom';


const Playroom = (props) => {
  const renderCorrectPlayroom = (param) => {
    switch(param) {
      case 'Werewolf':
        return <WerewolfPlayroom state={props.state}/>;
      case 'Next Round':
        return <NextRoundPlayroom state={props.state}/>;
      default:
        return 'No Playroom for that Gametype';
    }
  };

// TODO build playroom for different games
  return (
  <div className={styles.Playroom} data-testid="Playroom">
    {renderCorrectPlayroom(props.state.game.type)}
  </div>
)};

Playroom.propTypes = {
};

Playroom.defaultProps = {};

export default Playroom;
