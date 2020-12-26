import React, { useState }  from 'react';
import PropTypes from 'prop-types';
import styles from './optionList.module.css';
import { Typography, Grid, Paper, Button, Menu, MenuItem } from '@material-ui/core';
import {createBet} from '../../utils/index';


const OptionList = (props) => {
  let menuState = new Array(props.options.length).fill(null);
  const [state, setState] = useState({menuState:menuState});

return (
  <div className={styles.optionList} data-testid="optionList">
    <Paper style={{height:'100%', padding:'5px'}} elevation={2}>
      <Grid container spacing={2} 
                direction="column"
                alignItems="stretch"
                justify="center"
                >
          <Grid item>
            <Typography variant="h5">Options:</Typography>
          </Grid>
          <Grid item>
            {props.options
            .map((option, index)=> {
              let onClick = (event) => {
                let newMenuState = [...state.menuState];
                newMenuState[index] = event.currentTarget;
                setState({
                  ...state,
                  menuState: newMenuState, 
                });  
              }
              let makeBet = () => {
                createBet(props.gameId,option)
                handleClose();
              }
              let editOption = () => {
                handleClose();
              }
              let handleClose = () => {
                let newMenuState = [...state.menuState];
                newMenuState[index] = null;
                setState({
                  ...state,
                  menuState: newMenuState, 
                });  
              }
              return (
                <Paper style={{height:'100%', padding:'5px'}} elevation={2} key={option.title.concat(option.description)}>
                  <Menu
                    id={option.title.concat(option.description)}
                    anchorEl={state.menuState[index]}
                    open={Boolean(state.menuState[index])}
                    onClose={handleClose}
                  >
                    <MenuItem onClick={makeBet}>Make Bet</MenuItem>
                    {/* <MenuItem onClick={editOption}>Edit Option</MenuItem> */}
                  </Menu>
                  
                  <Button fullWidth={true} onClick={onClick}>
                    <Grid container
                      spacing={2} 
                      direction="column"
                      alignItems="stretch"
                      justify="center"
                      >
                        <Grid item>
                          <Typography variant="body1">{option.title}</Typography>
                        </Grid>
                        <Grid item>
                          <Typography variant="subtitle1">{option.description}</Typography>
                        </Grid>
                        <Grid item>
                          <Grid container
                              direction="row"
                              justify="space-evenly"
                              >
                          <Paper elevation={3}>
                            <Grid item 
                              style={{padding:'5px'}}
                              >
                              <Typography variant="subtitle1">{option.choiceA}</Typography>
                            </Grid>
                          </Paper>
                          <Paper elevation={3}>
                            <Grid item
                              style={{padding:'5px'}}
                              >
                              <Typography variant="subtitle1">{option.choiceB}</Typography>
                            </Grid>
                          </Paper>
                        </Grid>
                      </Grid>
                    </Grid>
                  </Button>
                </Paper>
                )
              }
          )}
          </Grid>
      </Grid>
    </Paper>
  </div>
)};

OptionList.propTypes = {};

OptionList.defaultProps = {};

export default OptionList;
